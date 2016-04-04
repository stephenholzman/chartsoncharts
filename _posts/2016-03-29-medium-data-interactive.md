---
layout: post
title: Wrangling Medium Data to Build a Serverless Interactive
description: "Building a D3 interactive with data too big to load everything into the browser and not quite big enough to require spinning up a database."
modified: 2016-03-29
tags: [Node, S3, D3, R, MySQL, Amazon Web Services, United Nations World Population Prospects, Population Pyramid]
categories: [Tutorials]
author: "Stephen Holzman"
image: "mediumTeaser.png"
---

Say you want to put out an interactive visualization. This interactive needs access to a lot of data that’s too much to load into the browser all at once. Say you don’t want to run a database server for client queries on this data.

This solution definitely does not apply to every situation, but this is how I built a United Nations World Population Prospects visualization and host it for super cheap.

<center><h2>The Chart</h2></center>
<div class="interactive" align="center">
<iframe src="/assets/interactives/UNWPP2015/" frameborder="0"> </iframe>
</div>

<center><h2>The Solution</h2></center>

Some situations absolutely require a database to have any hope of running well and securely. Anything with user personal data falls into this category. Liberal amounts of customization options, like when a user wants to see the income distribution of college graduates working in sales who live in Idaho broken down by sex, age groups, and race.

The United Nations data comes in at 45mb zipped in it's smallest form. There are really only about 300 options for a single geography variable I want to give users control over, which makes it possible to break up the big file into smaller files for each geogrpahy all hosted in a static data folder. 

There are many ways to accomplish this task. I'll warn that mine might look a bit weird because of context surrounding development. The first thing I did with this data was load it into R and promptly deposit everything to a local instance of MySQL.

{% highlight R %}
library(RMySQL)

UNpop <- read.csv("~/Downloads/WPP2015_INT_F3_Population_Annual_Single_Medium.csv", stringsAsFactors = FALSE)

con <- dbConnect(MySQL(),
                 user = 'username',
                 password = 'password',
                 host = '127.0.0.1',
                 dbname = 'UnitedNations')

dbWriteTable(con,"UNtest",UNpop,overwrite=T)
{% endhighlight %}

While it is possible to accomplish the immediate task of dividing the data entirely in R or Node, I sometimes like to keep larger data I am working with in a database. The RMySQL library is my current go-to library for no-fuss csv table writes. +1 endorsement.

The <a href="http://esa.un.org/unpd/wpp/Download/Standard/ASCII/" target="_blank">
United Nations data</a> is thankfully very clean. We can expect every country to have data from 1950 to 2100 and for the age range to be 0 to 80 before 1990 and 0 to 100 after. The top age group includes people that age and older. Each country has a unique code identifier.

This makes it a dream to work with, so my plan is to loop through queries on the database with a WHERE statement set to the numeric country code (the country names are complicated by special characters). I made a quick csv key using documentation info only available in xls,which you can download <a href="/assets/interactives/UNWPP2015/data/UnitedNationsGeoCodes.csv"
 target= "_blank">here</a> if you want to fully replicate this. Prep variables and load the csv:

{% highlight JavaScript %}
var mysql      = require('mysql');
var async = require('async');
var fs = require('file-system');

var connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'username',
  password : 'password',
  database : 'UnitedNations'
});

var columns = ["Geography", "Code"];
countries = [];

require("csv-to-array")({
   file: '/Users/birdy/Github/chartsoncharts/assets/interactives/UNWPP2015/data/UnitedNationsGeoCodes.csv',
   columns: columns
}, function (err, array) {
    
    //Rest of Code Here

};
{% endhighlight %}

The necessary libraries are loaded and MySQL connection settings are established. As soon as the csv loads, we execute the callback with the rest of the code.  

{% highlight JavaScript %}
  for(row in array){
    if(row!=0){
        countries.push(+array[row].Code);
    }
  }
  connection.connect();

    var req = async.forEach(countries, function(item,callback){

        years1950to1989 = [],
        years1990to2100 = [];

        for (i = 1950; i <= 2100; i++){
            if(i < 1990){
                years1950to1989.push(i);
            }else{
                years1990to2100.push(i);
            };
        };

        agesTo80 = [];
        agesTo100 = [];

        for (i = 0; i <= 100; i++){
            agesTo100.push(i);
            if(i <= 80){
                agesTo80.push(i);
            };
        };

        var popObject1950to1989 = {
            "type": ["population"],
            "label": [item],
            "year": years1950to1989,
            "age": agesTo80,
            "pop": {
                "Female": [],
                "Male": [];
            };
        };

        var popObject1990to2100 = {
            "type": ["population"],
            "label": [item],
            "year": years1990to2100,
            "age": agesTo100,
            "pop": {
                "Female": [],
                "Male": [];
            };
        };
{% endhighlight %}

The final popObjects are how I like to store population data. They are structured so that the "Male" and "Female" arrays will each be an array with a length equal to "age". Each of those arrays will contain a number of values equal to "year" of "type". I've kept it consistent between projects which makes lifting code a lot easier.

{% highlight JavaScript %}

        var maxCollection = [];

        for(age in agesTo80){
            popObject1950to1989.pop.Female.push([]),
            popObject1950to1989.pop.Male.push([]);
        }

        for(age in agesTo100){
            popObject1990to2100.pop.Female.push([]),
            popObject1990to2100.pop.Male.push([]);
        }

        connection.query('SELECT * FROM UNpop WHERE LocID = '+item, function(err, rows, fields) {
          if (err) throw err;
          for(row in rows){
            if(rows[row].Time < 1990){
                if(rows[row].Sex != "Both"){
                    popObject1950to1989["pop"][rows[row].Sex][rows[row].AgeGrpStart][rows[row].Time-1950] = rows[row].Value;
                    maxCollection.push(rows[row].Value);
                }

            }else{
                if(rows[row].Sex != "Both"){
                    popObject1990to2100["pop"][rows[row].Sex][rows[row].AgeGrpStart][rows[row].Time-1990] = rows[row].Value;
                    maxCollection.push(rows[row].Value);

                }
            }
          }

          var maxPop = Math.max.apply(null, maxCollection );

          cleanjson = [popObject1950to1989,popObject1990to2100,maxPop];

          fs.writeFile('/Users/birdy/Github/chartsoncharts/assets/interactives/UNWPP2015/data/'+item+'.json',JSON.stringify(cleanjson,null,'\t'));

        });

    })

    connection.end();
});

{% endhighlight %}

The final json that I write to disk for each country has 3 objects:

* [0] Population before 1990 
* [1] Population after 1990
* [2] A max value to base the x axis on.

Everything gets uploaded to an S3 bucket. Appropriate use of the D3 queue library enables fast loading of a new country when the user makes a selection. 