---
layout: post
title: Intermediate Responsive Chart Method Using D3
description: "Walkthrough of how you might code a full responsive line chart using D3"
modified: 2016-04-18
tags: [D3, Responsive Design]
categories: [Tutorials]
author: "Stephen Holzman"
image: "responsiveTeaser.png"
---

If you haven't already read it, a better place to start might be <a href="/tutorials/basic-responsive-d3/" target="_blank">the basic introduction to my responsive D3 code organization strategy.</a> That one covers only how to code a responsive x-axis and introduces the "calc", "update", "draw", and "resize" functions that I use to keep things straight in D3. This post extends that to a full chart and introduces a "load" function for bringing in data from a csv file.

Or maybe just jump right in!

Like everyone else, I enjoy reusing code because I'm lazy. As stated in the basic intro post, I want to make a chart with two lines of JavaScript and move on with my life.

{% highlight JavaScript %}

draw_chart();

d3.select(window).on("resize",resize_chart);

{% endhighlight %}

One line to draw the chart. One line to handle when the window resizes. Throw an iframe on the blog and reference the source to get a nice responsive chart with no fuss. <a href="/assets/interactives/responsive/example5.html" target="_blank">(Open in another window to play around if you would like)</a>

<div class="interactive" align="center">
<iframe src="/assets/interactives/responsive/example5.html" frameborder="0"> </iframe>
</div>

Naturally it is not quite that simple and there is a lot of fuss. So this method strives for as little fuss as possible! Literally everything about the chart is created by a function.

* **"calc"** functions set variables to certain values, but do not interact with the DOM in any way.

* **"draw"** functions add new elements to the DOM and invoke the necessary "calc" and "update" functions to render the intended feature.

* **"update"** functions modify existing DOM elements and invoke necessary "calc" functions.

* **"resize"** functions handle what happens when the window dimensions change, whether someone flips their phone to landscape or a browser window is resized.

* **"load"** functions pull data into the browser and then invoke the functions that would break if that data were not finished loading.

Everything also gets a consistent variable name designed to be as descriptive as possible. The function brackets combined with the variable names actually serve as pretty nice pseudo comment markers if you are new to D3. I like it because it is easy to Ctrl+F your way around the code to make adjustments. It is also incredibly easy to lift individual functions for other projects or just use this as a template. 


I possibly went a little overboard with dictating styling using JavaScript when I could have used CSS for this example. The upside of CSS is it would be easier in the longrun to apply constant styling. The upside of going through JavaScript is you know exactly what element you are breaking when making adjustments.

<center><h2>Full HTML + Script</h2></center>

{% highlight JavaScript %}

<!DOCTYPE html>
<meta charset="utf-8"/>
<meta name="HandheldFriendly" content="True">
<meta name="MobileOptimized" content="320">
<meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, maximum-scale=1.0, user-scalable=no">

<link rel="stylesheet" href="style2.css" type="text/css" media="screen"/>

<script src="/assets/d3/d3.min.js"></script>

<div id="container"></div>

<script>

//Establish how much screen real estate our chart has to work with
var calc_chartDimensions = function(){

  headerDimensions = {width: "100%", height: 100}

  citationDimensions = {width: "100%", height: 40}

  margin = {top: 50, left: 80, bottom: 50, right: 50}

  width = window.innerWidth - margin.left - margin.right

  height = window.innerHeight - headerDimensions.height - citationDimensions.height - margin.top - margin.bottom

}
//All functions managing the titles.

var calc_titles = function(){

  if(window.innerWidth > 600){
    titleText = "Widget Market in the United States"
  }else{
    titleText = "Widgets - United States"
  }

  subtitleText = "Supply and Demand"

}

var update_titlesAttr = function(){

  calc_titles()

  headerAttr = header
    .attr("id","header")
    .style("width",headerDimensions.width)
    .style("height", headerDimensions.height + "px")
    .style("position","fixed")
    .style("top","0px")
    .style("left","0px")
    .style("background-color","#333")
    .style("color","#FFF")
    .style("font-family","arial")

  if(window.innerWidth > 600){
    titleFontSize = "32px"
    subtitleFontSize = "20px"
  }else{
    titleFontSize = "28px"
    subtitleFontSize = "20px"
  }

  titleAttr = title
    .attr("id","title")
    .attr("class","title-text")
    .style("margin-top","10px")
    .style("margin-left","10px")
    .style("margin-bottom","3px")
    .style("font-size",titleFontSize)
    .text(titleText)

  subtitleAttr = subtitle
    .attr("id","subtitle")
    .attr("class","title-text")
    .style("margin-top","10px")
    .style("margin-left","10px")
    .style("margin-bottom","3px")
    .style("font-size",subtitleFontSize)
    .text(subtitleText)         
}

var draw_titles = function(){

  header = d3.select("#container")
    .append("div")

  title = header
    .append("h1")

  subtitle = header
    .append("h3")

  update_titlesAttr()


}
//All functions managing the citations.

var calc_citation = function(){

  sourceText = {text: "Source: My Donkey", link: "https://upload.wikimedia.org/wikipedia/commons/7/7b/Donkey_1_arp_750px.jpg"}

  authorText = {text: "@StephenHolz", link: "https://twitter.com/StephenHolz"}

}

var update_citationAttr = function(){

  calc_citation()

  citationAttr = citation
    .attr("id","citation")
    .style("width",citationDimensions.width)
    .style("height", citationDimensions.height + "px")
    .style("position","fixed")
    .style("bottom","0px")
    .style("left","0px")
    .style("background-color","#333")
    .style("color","#FFF")
    //.style("font-family","arial")

  sourceAttr = source
    .attr("id","source")
    .attr("class","title-text link")
    .style("margin-top","8px")
    .style("margin-left","10px")
    .style("margin-bottom","3px")
    .style("font-size","20px")
    .style("float","left")
    .text(sourceText.text)
    .on("click", function(){
      window.open(sourceText.link)
    })

  authorAttr = author
    .attr("id","author")
    .attr("class","title-text link")
    .style("margin-top","8px")
    .style("margin-left","10px")
    .style("margin-right","10px")
    .style("margin-bottom","3px")
    .style("font-size","20px")
    .style("float","right")
    .text(authorText.text)
    .on("click", function(){
      window.open(authorText.link)
    })          
}

var draw_citation = function(){

  citation = d3.select("#container")
    .append("div")

  source = citation
    .append("a")

  author = citation
    .append("a")

  update_citationAttr()


}
//All functions managing the x Axis.
var calc_xScale = function(){

  xScale = d3.scale.linear()
    .range([0, width])
    .domain([0, 400])

}

var calc_xAxis = function(){

  if(window.innerWidth > 700){
    xNumberTicks = 8
  }else if(window.innerWidth > 500){
    xNumberTicks = 4  
  }else{
    xNumberTicks = 2
  }

  xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("bottom")
    .ticks(xNumberTicks)

}

var update_xAxisAttr = function(){

  calc_xScale()
  calc_xAxis()

  xAxisAttr = xAxisG
    .attr("id","xAxis")
    .attr("class","x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis)

  xAxisLabelAttr = xAxisLabel
    .attr("transform","translate(" + (width/2) + ",40)")
    .style("font-size","22px")
    .style("font-family","arial")
    .attr("text-anchor","middle")
    .text("Quantity")
}

var draw_xAxis = function(){

  xAxisG = chartG.append("g")

  xAxisLabel = xAxisG.append("text")

  update_xAxisAttr()

}

//All functions managing the y Axis.
var calc_yScale = function(){

  yScale = d3.scale.linear()
    .range([height, 0])
    .domain([0, 10])

}

var calc_yAxis = function(){

  yAxis = d3.svg.axis()
    .scale(yScale)
    .orient("left")
    .ticks(4)
    .tickFormat(function(d){
      return "$" + d
    })

}

var update_yAxisAttr = function(){

  calc_yScale()
  calc_yAxis()

  yAxisAttr = yAxisG
    .attr("id","yAxis")
    .attr("class","y axis")
    .call(yAxis)

  yAxisLabelAttr = yAxisLabel
    .attr("transform","translate(" + (-50) + ","+ (height/2) + ")rotate(-90)")
    .style("font-size","22px")
    .style("font-family","arial")
    .attr("text-anchor","middle")
    .text("Price")
}

var draw_yAxis = function(){

  yAxisG = chartG.append("g")

  yAxisLabel = yAxisG.append("text")

  update_yAxisAttr()

}
//All functions managing the data and lines
var load_data = function(){

  d3.csv("supply-demand.csv", function(data) {
    draw_lines(data)
  })


}
var calc_lines = function(){

  supplyLine = d3.svg.line()
    .x(function(d){
      return xScale(d.supplied)
    })
    .y(function(d){
      return yScale(d.price)
    })

  demandLine = d3.svg.line()
    .x(function(d){
      return xScale(d.demanded)
    })
    .y(function(d){
      return yScale(d.price)
    })

}
var update_linesAttr = function(){

  calc_lines()

  supplyColor = "#B1B1F0"
  demandColor = "#E4E49A"

  supplyAttr = supply
    .attr("d",supplyLine)
    .attr("stroke",supplyColor)
    .attr("stroke-width","6px")
    .attr("fill","none")

  demandAttr = demand
    .attr("d",demandLine)
    .attr("stroke",demandColor)
    .attr("stroke-width","6px")
    .attr("fill","none")

  supplyLabelAttr = supplyLabel
    .attr("transform","translate(" + xScale(350) + ","+ yScale(7) + ")")
    .style("font-size","22px")
    .style("font-family","arial")
    .style("fill",supplyColor)
    .append("text")
    .text("Supply")

  demandLabelAttr = demandLabel
    .attr("transform","translate(" + xScale(200) + ","+ yScale(1) + ")")
    .style("font-size","22px")
    .style("font-family","arial")
    .style("fill",demandColor)
    .append("text")
    .text("Demand")

}

draw_lines = function(data){

  supply = chartG
    .append("path")
    .datum(data)

  demand = chartG
    .append("path")
    .datum(data)

  supplyLabel = chartG.append("a")

  demandLabel = chartG.append("a")

  update_linesAttr()

}
//All functions managing the chart wrapper
var update_chartAttr = function(){

  chartAttr = chart
    .attr("id","chart0")
    .attr("width",width+margin.left+margin.right)
    .attr("height",height+margin.top + margin.bottom)
    .style("position","fixed")
    .style("top",headerDimensions.height+"px")
    .style("left", "0px")

  chartGAttr = chartG
    .attr("transform","translate(" + margin.left + "," + margin.top + ")")
}

var draw_chart = function(){

  calc_chartDimensions()

  draw_titles()

  chart = d3.select("#container")
    .append("svg")

  chartG = chart
    .append("g")

  update_chartAttr()

  draw_xAxis()
  draw_yAxis()

  draw_citation()

  load_data()
}

//Resize function
var resize_chart = function(){

  calc_chartDimensions()

  update_titlesAttr()
  update_citationAttr()

  update_chartAttr()

  update_xAxisAttr()
  update_yAxisAttr()

  update_linesAttr()

}

//Draw the initial chart and be ready for window resize
draw_chart()

d3.select(window).on("resize",resize_chart)

</script>

{% endhighlight %}

<center><h2>style2.css</h2></center>
{% highlight css %}

#container{
  width:100%;
  height:100%;
}
.axis path, .axis line{
  fill: none;
  stroke: #000;
}
.link:hover{
  cursor:pointer;
}
#chart0{
  background-color:#FAFAFA;
}

{% endhighlight %}

<center><h2>supply-demand.csv</h2></center>
{% highlight HTML %}

"price","supplied","demanded"
0,0,200
1,40,190
2,80,180
3,120,170
4,160,160
5,200,150
6,240,140
7,280,130
8,320,120
9,360,110
10,400,100

{% endhighlight %}
