---
layout: post
title: Keeping D3 Visualizations Current with AWS Lambda
description: "How to keep D3 visualizations up-to-date on the cheap using AWS Lambda, S3 Static Sites, and Public APIs"
modified: 2016-03-26
tags: [Amazon Web Services, Interactive Charts, Lambda, S3, Huffington Post Pollster]
categories: [Tutorials]
author: "Stephen Holzman"
image: "awsLambda.png"
---
It has been about a year and a half since I set up my first Linux server and I still get nightmares.

It barely even counted as a real server. CentOS running on a Dell OptiPlex 9010 for the purpose of sharing a MySQL database with a maximum of 10 concurrent users. Pretty basic job in hindsight, but picking a Linux distribution and getting everything configured for any server job takes time and tons can go wrong if servers are not "your thing". 

One of the articles I stumbled across that stayed with me was <a href="http://www.thegeekstuff.com/2011/07/lazy-sysadmin/"  target = "_blank">this post on the inherent virtue of lazy SysAdmins.</a> It turns out what looks like laziness might actually just be preparedness--which I will attempt to replicate with charts. Lazy visualization practitioner is best visualization practitioner.

<center><h2>What is the best way to keep charts up to date?</h2></center>

The chart I'm working on is a single-page election data explorer that currently has national polling estimates and delegate counts for the United States election.

<div class="interactive" align="center">
<iframe src="/election/" frameborder="0"> </iframe>
</div>

Naturally everything is designed to be responsive and is a continuation of my efforts to make mobile friendly charts. D3 is being used to manipulate the DOM aggressively. <a href="/election/" target="_blank">Check it out in a new window and play around.</a> What I don't want to do is have to go in and adjust code or manually upload new data every time a new poll is realased.

Thanks to the lazy sysadmins at Amazon Web Services and awesome Huffington Post Data team, I'm using the Lambda service and Pollster API to keep the polling portion of the chart up-to-date. Lambda let's you run snippets of code at set intervals or in response to events without having to spin up servers. **Repeat, no server administration-ing necessary**.

This is a pretty big deal. For now, Lambda supports Python, Node, and Java. Mine is in Node, which is easy to figure out if you just know JavaScript. The entirety of this code calls the Huffington Post Pollster API, munges the returned JSON into an easily processed CSV for the D3 multi-line poll chart, uploads that CSV to the S3 bucket the visualization points to, and closes out the Lambda function.

Total cost to run this function every day or even a few times a day rounds to $0.00 per month.

{% highlight JavaScript %}

//Load necessary javascript libraries
var request = require('request');
var async = require('async');
var AWS = require('aws-sdk');
var json2csv = require('json2csv');

/* The handler function is the main function wrapper.
 * Event is an object passed to the function by Lambda when it is called.
 * Because this is scheduled, it is not dependent on any of the event properties.
 * Context is an object passed by Lambda that contains methods for terminating the function when done.
 */

exports.handler = function(event, context){

    /* URL is the API call
     * Keyname is the filename
     * Choices are party candidates I'm interested in.
     */

    var requestUrls = [
        {
            "url":"http://elections.huffingtonpost.com/pollster/api/charts/2016-national-gop-primary.json",
            "keyname":"election/data/gop_national_estimates.csv",
            "choices":["Trump","Cruz","Rubio","Kasich","Carson","Bush","Christie","Rand Paul","Fiorina","Jindal"]
        },
        {
            "url":"http://elections.huffingtonpost.com/pollster/api/charts/2016-national-democratic-primary.json",
            "keyname":"election/data/dem_national_estimates.csv",
            "choices":["Clinton","Sanders"]
        };
    ];

    /* Define function that uploads cleaned CSV to S3 that will be called later in request callback
     * Uploadobject is the body returned by the API request
     * Keyname is the keyname property from the requestUrls item.
     * Choices is the choices property from the requestUrls item.
     */

    var uploadS3 = function(uploadobject,keyname,choices){


        var s3 = new AWS.S3();
        var prepJSONforCSV = [];
        var partiesdone = 0;

        /* Build JSON that works with json2csv from uploadobject
         */

        uploadobject.estimates_by_date.forEach(function(d,i){

            obj = new Object();
            obj.date = d.date;
            for(c in choices){
                for(value in d.estimates){
                    if(d.estimates[value].choice === choices[c]){
                        obj[choices[c]] = d.estimates[value].value;
                    };       
                };             
            };
            prepJSONforCSV.push(obj);

        });

        /* Convert json to csv
         * Fields are csv headers
         */

        var fields = choices;
        fields.push("date");

        json2csv({ data: prepJSONforCSV, fields: fields }, function(err, csv) {

            if (err) console.log(err);

            /* AWS access.
             * Credentials are taken care of by AWS IAM.
             * Creates a bucket for files if it doesn't exist.
             * uploads object with keyname as filename.
             */

            s3.createBucket({Bucket: 'chartsoncharts.com'}, function() {

                var params = {Bucket: 'chartsoncharts.com', Key: keyname, Body: csv}

                s3.putObject(params, function(err, data) {

                    if (err){
                        console.log(err);
                        //If there's an error, context fail let's Lambda know you failed and ends the function.
                        context.fail();
                    }else{
                        console.log("Successfully uploaded data to S3!");
                        partiesdone++;
                        if(partiesdone===2){
                            //If the expected number of objects have been uploaded, context succeed let's Lambda know you succeeded and ends the function.
                            context.succeed(); 
                        }       
                    }
                });
            });

        });

    };
    /*Actually run the code.
     *I chose to put context.succeed() in putObject function, but could just as easily be in the async.foreach callback here.
     */
    var req = async.forEach(requestUrls, function(item,callback){
        
        request({
            url: item.url,
            json: true
        }, function(error, response, body){
            uploadS3(body,item.keyname,item.choices);
        }, function(error){
            context.fail();
        })

    });

};

{% endhighlight %}

<center><h2> Benefits </h2></center>

Instead of hitting the Huffington Post API with dozens of extra API calls (dozens!) and making client browsers do the work of data manipulation, Lambda removes the need for a lot of redundant computing.

* Basically free for this use case.

* No servers to break at the worst times.

* Way to save client browsers from extra work/data 

* Keep charts updated even while on vacation.








