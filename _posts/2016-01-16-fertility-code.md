---
layout: post
title: Fertility Code
description: "The code behind the Fertility Trends article."
modified: 2016-01-26
tags: [D3, code, R]
categories: [Code]
author: "Stephen Holzman"
---

It might be appropriate to listen to Kenny Rogers and Gladys Knight sing "<a href="https://www.youtube.com/watch?v=ye5EFc89vDw" target="_blank">If I Knew Then What I Know Now"</a> while reading over this code.

It was written using the HIWAH method (Hit It With A Hammer). This is my second D3/JavaScript project and I tried to use good fundamentals, but it was difficult to plan ahead how the different parts of the chart would interlock programmatically without having used any of the parts before. So this is a warning about liberal global variable use, scope ignorance, and possibly redundant functions.

While the code is dirty, the result is pretty clean. Off the bat I knew I wanted everything to be based on functions so that I can lift components for future projects with little effort. I ended up leaning on global variables a little too heavily to declare complete success, but I'll revise a lot of this as I gain familiarity with how things work in JS.

For posterity and hopefully your benefit, this is the R code to get Human Fertility Database data. It requires you to <a href="http://humanfertility.org/cgi-bin/registration.php" target="_blank">register</a> as the data license forbids redistributing the data to ensure users have access to the documentation.

{% highlight R %}
####Setup####
library(HMDHFDplus)
library(jsonlite)
library(dplyr)
options(scipen=10)

####Read HFD username and password from local file####
####You may also just enter them manually####
HFDcredentials <- read.csv("~/Location/Path/HFD.csv", stringsAsFactors = FALSE)

####Pull list of Human Fertility Collection and Database countries for labeling stuff and getting data####
HFCcountries <- getHFCcountries(names = TRUE)
HFDcountries <- getHFDcountries()

####Get data from HFD, may take a minute####
for (country in HFDcountries){
  assign(paste(country,"data",sep=""),readHFDweb(CNTRY = country, item ="asfrRR", username=HFDcredentials$username, password = HFDcredentials$password))
}

####Prep to join country names to HFD codes as getHFDcountries() does not by default####
countrylist <- NULL
countrylist$code <- HFDcountries

alldata <- list()
count <-1
####Munge pulled data to a nice JSON for use with D3####
for(country in HFDcountries){
  
  tempmatrix <- matrix(nrow=44,ncol=length(seq(min(get(paste(country,"data",sep=""))$Year),max(get(paste(country,"data",sep=""))$Year))))

  for(year in seq(min(get(paste(country,"data",sep=""))$Year),max(get(paste(country,"data",sep=""))$Year))){
    tempmatrix[,1 + year - min(get(paste(country,"data",sep=""))$Year)] <- as.vector(filter(get(paste(country,"data",sep="")), Year==year)$ASFR)
  }
  
  colnames(tempmatrix) <- as.character(seq(min(get(paste(country,"data",sep=""))$Year),max(get(paste(country,"data",sep=""))$Year)))

  tempmatrix <- round(tempmatrix,5)
  tempmatrix <- as.list(data.frame(tempmatrix))
  
  tempjson <- NULL
  tempjson$minyear <- min(get(paste(country,"data",sep=""))$Year)
  tempjson$maxyear <- max(get(paste(country,"data",sep=""))$Year)
  tempjson$countryname <- HFCcountries[match(country,HFCcountries$Code),1]
  if(country == "FRATNP"){
    tempjson$countryname <- "France"
  }
  tempjson$ages <- seq(12,55)
  tempjson$fertilityrates <- tempmatrix
  alldata[count] <- list(tempjson)
  names(alldata)[count] <- country

  assign(paste(country,"json",sep=""),tempjson)
  
  countrylist$country[match(country,HFDcountries)] <- HFCcountries[match(country,HFCcountries$Code),1]
  count <-count + 1
}
alldata <- toJSON(alldata,digits=6,pretty=TRUE)
write(alldata,paste("~/Location/Path/alldata.json",sep=""))

{% endhighlight %}

This is the JavaScript/D3 code that creates everything.

{% highlight JavaScript %}
<!DOCTYPE html>
<meta charset="utf-8"/>
<link rel="stylesheet" href="style.css" type="text/css" media="screen"/>

<div id="main-wrapper"></div>
<noscript>

<figure>
  <img src="/images/usa-vs-japan-fertility.gif" alt="">
  <figcaption>You need to enable JavaScript to view the full interactive version of this chart.</figcaption>
</figure>

</noscript>
<script src="d3.js"></script>

<script>

//Input variables for the chart functions
var chartsizeadjust = 1;
var target = "#main-wrapper";
var currentyear = 1947;
var id = "country_controller";
var speed = 200;
var paused = false;


//Data variables to include in the table-controller
var variables = {
  "CountrySelect":{
    "title":"Select Countries Below",
    "smalltitle":"Country",
    "type":"select",
    "align":"align-left"
  },
  "TotalFertilityRate":{
    "title":"Total Fertility Rate",
    "smalltitle":"TFR",
    "type":"stat",
    "align":"align-right",
    "get":"fertilityrates"
  }
};

//how many observations to display in the table
var observations = {
  "ob0":{
    "color":"blue",
    "default":"United States of America",
    "id":"ob0",
    "countryname":"United States of America",
    "code":"USA"

  },
  "ob1":{
    "color":"red",
    "default":"Japan",
    "id":"ob1",
    "countryname":"Japan",
    "code":"JPN"
  },
  "ob2":{
    "color":"yellow",
    "default":"None",
    "id":"ob2",
    "countryname":"None",
    "code":"None"
  },
  "ob3":{
    "color":"teal",
    "default":"None",
    "id":"ob3",
    "countryname":"None",
    "code":"None"
  }
}


/*
Definitions for the controller_table function inputs:
target = element to attach the table to
variables = columns in table
observations = rows in table
id = id for the table
data = json file created by the R munging code
*/

var controller_table = function(target,variables,observations,id,data){

  //
  var table = d3.select(target).append("div")
                    .attr("id",id)
                    .attr("class","controller_table");
  var headers = table.append("nav")
              .attr("id","headers")
              .append("ul");


  for (variable in variables){
    
    headers.append("li")
        .append("a")
        .attr("id",variable)
        .attr("class",eval("variables."+variable+".align")+" "+eval("variables."+variable+".type"))
        .text(eval("variables."+variable+".title"));
  };

  for(observation in observations){

    var row = table.append("nav")
              .attr("id",eval("observations."+observation+".id"))
              .append("ul");

    for(variable in variables){
      if(eval("variables."+variable+".type")==="select"){

        //Append list items and appropriate containers for select
        var selector = row.append("li")
                  .append("div")
                  .attr("id",eval("observations."+observation+".id")+"dropdown")
                  .attr("class",eval("observations."+observation+".color")+" styled-select")
                  .append("select")
                  .attr("id",eval("observations."+observation+".id")+"selection");
        
        selector.on("change",function(){
          d3.select(".year-label").remove();
          var sel = document.getElementById(this.id);
          var opts = sel.options;
          var fullid = this.id;
          
          observations[fullid.slice(0,3)].code = opts[[this.selectedIndex][0]].getAttribute("code");
          observations[fullid.slice(0,3)].countryname = opts[[this.selectedIndex][0]].innerHTML;
          d3.select("#chart0wrapper").selectAll(".line").remove();
          draw_lines(observations,globaldata);
          d3.select("#chart0slider").remove();
          controller_slider("#anim-wrapper",slider_id,slider_dimensions,currentyear); 

          
        });
        //Populate Select Options
        selector.append("option")
            .text("None")
            .attr("code","None");
            
        
        
        for(item in data){
          selector.append("option")
              .attr("code",item)
              .text(eval("data."+item+".countryname"));
        };


        //Set Default Select Options
        var sel = document.getElementById(eval("observations."+observation+".id")+"selection");
        var opts = sel.options;

        for(var opt, j = 0; opt = opts[j]; j++) {
          if(opt.value === eval("observations."+ observation +".default")) {
              sel.selectedIndex = j;        
              break;
            }
        };


      }else if(eval("variables."+variable+".type")==="stat"){

        row.append("li")
          .append("a")
          .attr("id",observation+"stat");
      };
      
    };


  };
};

//Set up inputs for drawing the chart based on available pixels and on window resize.
var calcchart0 = function(){
  chart_id = "chart0",
  chart_dimensions = {"width":window.innerWidth*.9*chartsizeadjust, "height":window.innerHeight/2},
  chart_axisinfo = {"xdomain":[12,50],"ydomain":[0,.3],"xlabel":"Age","ylabel":"Births per Woman"};
}
calcchart0();
d3.select(window).on('resize',calcchart0());

/*
Definitions for the draw_2dchart function inputs:
target = element to attach to
id = id for the chart
dimensions = dimension object with height and width properties
axisinfo = set ydomain and xdomain
*/
var draw_2dchart = function(target,id,dimensions,axisinfo){

  //More setup for responsive chart
  var chartparameters = function(){
    margin = {top: 20, right:.07*dimensions.width,bottom: 60, left: 60},
    width = dimensions.width - margin.left - margin.right,
    height = dimensions.height - margin.top - margin.bottom;
    xScale = d3.scale.linear().range([0,width]);
    yScale = d3.scale.linear().range([height,0]);
    xAxis = d3.svg.axis()
          .scale(xScale)
          .orient("bottom");
    yAxis = d3.svg.axis()
          .scale(yScale)
          .orient("left");

    xScale.domain(axisinfo.xdomain);
    yScale.domain(axisinfo.ydomain);
  };

  chartparameters();

  //Create a wrapper for the chart in case we want to create more than one in future projects.
  var chartwrapper = d3.select(target)
              .append("div")
              .attr("id",id+"wrapper")
              .attr("width",width + margin.left + margin.right)
              .attr("height",height + margin.top + margin.bottom);;

  //Attach the chart svg
  var chartsvg = chartwrapper
        .append("svg")
        .attr("id",id+"svg")
        .attr("class","chart")
        .attr("width",width + margin.left + margin.right)
        .attr("height",height + margin.top + margin.bottom);
  //Attach g element to the svg
  var chart = chartsvg
        .append("g")
        .attr("id",id+"g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    
  //Attach axis g elements to the other g element
  HorizAxis = chart.append("g")
      .attr("class","x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

  VertAxis = chart.append("g")
      .attr("class","y axis")
      .call(yAxis);

  xLabel = chart.append("text")
        .attr("class", "x label")
        .attr("text-anchor", "end")
        .attr("x", width)
        .attr("y", height + 40)
        .text(axisinfo.xlabel);

  yLabel = chart.append("text")
        .attr("class", "y label")
        .attr("text-anchor", "end")
        .attr("y", -60)
        .attr("x", -20)
        .attr("dy", ".75em")
        .attr("transform", "rotate(-90)")
        .text(axisinfo.ylabel);

  //Chart animated resizing function, mostly recalculating based on pixels available
  var resizechart = function(){
    chart_dimensions = {"width":window.innerWidth*.9*chartsizeadjust, "height":window.innerHeight/2},

    margin = {top: 20, right:.07*dimensions.width,bottom: 60, left: 60},
    width = chart_dimensions.width - margin.left - margin.right;
    height = chart_dimensions.height - margin.top - margin.bottom;
    xScale.range([0, width]);
      yScale.range([height, 0]);

      slider_dimensions = {"width":window.innerWidth*chartsizeadjust-100,"height":20};

      slideMargin = {top: 2, right: 7, bottom: 2, left: 7},
        slideWidth = slider_dimensions.width - slideMargin.left - slideMargin.right,
        slideHeight = slider_dimensions.height - slideMargin.bottom - slideMargin.top;

    HorizAxis
      .transition()
      .duration(001)
      .call(xAxis)
      .attr("transform", "translate(0," + height + ")")

    VertAxis
      .transition()
      .duration(001)
      .call(yAxis)

    d3.select("#chart0svg")
      .transition()
      .duration(001)
      .attr("width",width + margin.left + margin.right)
      .attr("height",height + margin.top + margin.bottom)

    chartwrapper
      .transition()
      .duration(001)
      .attr("width",width + margin.left + margin.right)
      .attr("height",height + margin.top + margin.bottom)

    xLabel
      .transition()
      .duration(001)
      .attr("x", width)
      .attr("y", height + 40);  

    yLabel
      .transition()
      .attr("y", -60)
      .attr("x", -20)
      .attr("dy", ".75em")

    //Lazy way to update the slider. Just remove it and redraw.
    d3.select("#chart0slider").remove();

    controller_slider("#anim-wrapper",slider_id,slider_dimensions,currentyear); 



    //Find the lines currently on the chart and transition them
    for(observation in observations){
      if(eval("observations."+observation+".code")!=="None"){
        selector = d3.select("#"+observation+"line");

        getcoordinates(eval("observations."+observation+".code"),currentyear,globaldata);

        selector
          .transition()
          .duration(.001)
          .attr("d",line(collection));    
      };
    };

    d3.select(".year-label")
      .transition()
      .duration(.001)
      .attr("x",width)
      .attr("y",60)
        
  };

  d3.select(window).on('resize',resizechart);
};

//Setup slider input variables
var slider_id = "chart0",
  slider_dimensions = {"width":window.innerWidth*chartsizeadjust-100,"height":20};

//Function that adds a slider to the DOM, same definitons as draw_2dchart with manipulated_variable being the year variable in this viz.

var controller_slider = function(target,id,dimensions,manipulated_variable,data){

  //Slider setup
  slideMargin = {top: 2, right: 7, bottom: 2, left: 7},
    slideWidth = dimensions.width - slideMargin.left - slideMargin.right,
    slideHeight = dimensions.height - slideMargin.bottom - slideMargin.top;

  xBar = d3.scale.linear()
            .domain([latestmin,earliestmax])
            .range([0, slideWidth]);

  //Establish brush 
  var brush = d3.svg.brush()
            .x(xBar)
            .extent([0,0])
            .on("brush", brushed);

  //Add svg and g element to the target wrapper
  svgSlider = d3.select(target).append("svg")
          .attr("id",id+"slider")
            .attr("width", slideWidth + slideMargin.left + slideMargin.right)
            .attr("height", slideHeight + slideMargin.top + slideMargin.bottom)
            .append("g")
            .attr("transform", "translate(" + slideMargin.left + "," + slideMargin.top + ")");
  //transform it
  svgSlider.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + slideHeight / 2 + ")")
            .call(d3.svg.axis()
                .scale(xBar)
                .orient("bottom")
                .ticks(0)
                .tickSize(0)
                .tickPadding(12))
            .select(".domain")
            .select(function() { return this.parentNode.appendChild(this.cloneNode(true)); })
                .attr("class", "halo");

  slider = svgSlider.append("g")
            .attr("class", "slider")
            .call(brush);

  slider.selectAll(".extent,.resize")
            .remove();

  slider.select(".background")
            .attr("height", slideHeight)
            .style("cursor", "col-resize");

  //Append the handle circle to the slider. Could be another shape.
  handle = slider.append("circle")
            .attr("class", "handle")
            .attr("transform", "translate(0," + slideHeight / 2 + ")")
            .attr("r", 6)
            .attr("cx", xBar(currentyear));

  //Update the year value, this could use some cleaning for lifting function to future projects
  var year_value = d3.select("#year_value");
        
  year_value.text(manipulated_variable);

  //Brushed function
  function brushed() {
      
      //Stop the animation!
      slider_brushed = true;
      paused = true;

      value = brush.extent()[0];
          
      if (d3.event.sourceEvent) {
        value = Math.round( xBar.invert(d3.mouse(this)[0]) );
        if (value < latestmin) value = latestmin;
        else if (value > earliestmax) value = earliestmax;
        brush.extent([value, value]);
                
        year_value.text(value);
        handle.attr("cx", xBar(value));

        currentyear = value;
        
        update_lines(.001);
        d3.select(".year-label")
          .text(currentyear);
      };

      
  };              
};

//Same definitions as above
var draw_lines = function(observations,data){
  countries = [];
  for(observation in observations){   
    countries.push(eval("observations."+observation+".code"));
  }

  getboundaryyears(data);
  if (currentyear < latestmin){
    currentyear = latestmin;
  };
  

  for(observation in observations){
    if(eval("observations."+observation+".code")!=="None"){
      var chart = d3.select("#chart0g");

      line = d3.svg.line()
          .x(function(d) {return xScale(d.xvalue); })
          .y(function(d) {return yScale(d.yvalue); });

      getcoordinates(eval("observations."+observation+".code"),currentyear,globaldata);

      //getTotalFertilityRate(globaldata,countrycode,currentyear);

      d3.select("#"+eval("observations."+observation+".id")+"stat").text(getTotalFertilityRate(globaldata,eval("observations."+observation+".code"),currentyear));
      var path = chart.append("path")
              .datum(collection)
              .attr("id",eval("observations."+observation+".id")+"line")
              .attr("class", "line "+eval("observations."+observation+".color"))
              .attr("d", line);
    }else if(eval("observations."+observation+".code")==="None"){
      d3.select("#"+eval("observations."+observation+".id")+"stat").text("NA")
    };
  };  

  yearLabel = chart.append("text")
          .attr("class","year-label")
          .attr("text-anchor","end")
          .attr("x",width)
          .attr("y",60)
          .text(currentyear);

};
var update_lines = function(speed){
  for(observation in observations){
    if(eval("observations."+observation+".code")!=="None"){
      var path = d3.select("#"+eval("observations."+observation+".id")+"line");

      
      getcoordinates(eval("observations."+observation+".code"),currentyear,globaldata);
      
      path
        .transition()
        .duration(speed)
        .attr("d", line(collection));

      d3.select("#"+eval("observations."+observation+".id")+"stat").text(getTotalFertilityRate(globaldata,eval("observations."+observation+".code"),currentyear));
    };
  };

  
};
var getboundaryyears = function(data){
  minyears = [],
  maxyears = [];

  countries.forEach(function(d){
      
    if(d!=="None"){
      minyears.push(eval("data."+d+".minyear[0]"))
      maxyears.push(eval("data."+d+".maxyear[0]"))
    }

  });

  setmin = Math.min(...minyears),
  setmax = Math.max(...maxyears),
  latestmin = Math.max(...minyears),
  earliestmax = Math.min(...maxyears);
  //currentyear = latestmin;
};

function getcoordinates(countrycode,year,data) {
  if(countrycode!=="None"){
    collection = [];
              
    for (j = 12; j <51; j+=1){
      var obj = new Object();
        obj.xvalue = j;
        obj.yvalue = eval("globaldata."+countrycode+".fertilityrates.X"+year+"[j-12]");
        collection[j-12] = obj;
    };
  }
};

function getTotalFertilityRate(data,countrycode,year){
  var agespecificrates = eval("data."+countrycode+".fertilityrates.X"+year);
  var sum = 0;

  for(var i = 0, length = agespecificrates.length; i < length; i++){
    sum += agespecificrates[i];
  };

  return(parseFloat(sum.toPrecision(3)));
};
globaldata = null

function timer(){
  if (paused === false){

    d3.select(".year-label")
            .text(currentyear);

    if (currentyear === latestmin){

      handle.attr("cx", xBar(currentyear));

      update_lines(speed);
      currentyear = currentyear + 1;
      setTimeout(timer,speed*3);
    }else if (currentyear < earliestmax){
      
      handle.attr("cx", xBar(currentyear));

      update_lines(speed);
      currentyear = currentyear + 1;
      setTimeout(timer,speed);
    }else{
      
      handle.attr("cx", xBar(currentyear));
      update_lines(speed);
      currentyear = latestmin;
      setTimeout(timer,speed*8);    
    };
  }else{
    d3.select("#play-controller").attr("class","paused")
    currentyear = currentyear-1
    d3.select(".year-label")
            .text(currentyear);
  };  
};

function controller_animation(target){
  var anim_wrapper = d3.select(target)
      .append("div")
      .attr("id","anim-wrapper")

  var background = d3.select("#anim-wrapper")
    .append("div")
    .attr("id","play-wrapper")

  var playpause = d3.select("#play-wrapper")
    .append("div")
    .attr("id","play-controller")
    .attr("class","playing");
    

  d3.select("#play-controller").on("click",function(){
    if (paused === true){
      paused = false;
      d3.select(this).attr("class","playing");
      setTimeout(timer,speed);
    }else{
      paused = true;
      d3.select(this).attr("class","paused")
    };
  });

};
d3.json("data/alldata.json", function(data) {
  globaldata = data
  controller_table(target,variables,observations,id,data);
  draw_2dchart(target,chart_id,chart_dimensions,chart_axisinfo);
  draw_lines(observations,data);
  controller_animation("#chart0wrapper");
  controller_slider("#anim-wrapper",slider_id,slider_dimensions,currentyear,globaldata);
  getTotalFertilityRate(data,"USA",2010);
      
  setTimeout(timer,speed);
  d3.selectAll("select").on("click",function(){
    paused = true;
  });
});

</script>
{% endhighlight %}


