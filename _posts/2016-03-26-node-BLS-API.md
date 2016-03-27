---
layout: post
title: Bureau of Labor Statistics API Node Code
description: "Calling the BLS API using Node"
modified: 2016-03-26
tags: [Node, Amazon Web Services, S3, Lambda, Bureau of Labor Statistics, code, API]
categories: [Code]
author: "Stephen Holzman"
image: "BLSteaser.png"
---

Messing around with the Bureau of Labor Statistics API in R earlier this week, I noticed there were no Node examples in the BLS documentation. Nothing fancy here, just supplementing those examples. Either use with Lambda to upload to S3, or locally and save to your file system.

<center><h1>AWS Lambda Upload to S3</h1></center>
{% highlight JavaScript %}

//Load necessary javascript libraries
var request = require('request');
var AWS = require('aws-sdk');

/* The handler function is the main function wrapper.
 * Event is an object passed to the function by Lambda when it is called.
 * Because this is scheduled, it is not dependent on any of the event properties.
 * Context is an object passed by Lambda that contains methods for terminating the function when done.
 */

exports.handler = function(event, context){

    /* Define function that uploads JSON to S3 that will be called later in request callback
     * Uploadobject is the body returned by the API request
     * Keyname is the path to save it in the S3 bucket.
     */

    var uploadS3 = function(uploadobject,keyname){


        var s3 = new AWS.S3();

        s3.createBucket({Bucket: 'chartsoncharts.com'}, function() {

            var params = {Bucket: 'chartsoncharts.com', Key: keyname, Body: uploadobject}

            s3.putObject(params, function(err, data) {

                if (err){
                    console.log(err);
                    //If there's an error, context fail let's Lambda know you failed and ends the function.
                    context.fail();
                }else{
                    console.log("Successfully uploaded data to S3!");  
                }
            });
        });

    };
    /*Actually run the code.
     */
    request.post(
        'http://api.bls.gov/publicAPI/v2/timeseries/data/',
        { json:
            { 
                "seriesid":["LNS14000004", "LNS14000005","LNS14000007","LNS14000008"],
                "startyear":"2007",
                "endyear":"2016"
            }    
        },
        function (error, response, body) {
            if (!error && response.statusCode == 200) {

                console.log(body);
                uploadS3(JSON.stringify(body,null,4),"Some/Path/BLS/BLStest.json");
                context.succeed()
             }
        }
    );

}

{% endhighlight %}

<center><h1>Local Version</h1></center>
{% highlight JavaScript %}
var request = require("request");
var fs = require("file-system");
request.post(
    "http://api.bls.gov/publicAPI/v2/timeseries/data/",
    { json:
        { 
            "seriesid":["LNS14000004", "LNS14000005","LNS14000007","LNS14000008"],
            "startyear":"2007",
            "endyear":"2016"
        }    
    },
    function (error, response, body) {
        if (!error && response.statusCode == 200) {

            console.log(body);
            fs.writeFile("/Some/File/Path/BLStest.json",JSON.stringify(body,null,4))
         }
    }
);
{% endhighlight %}
