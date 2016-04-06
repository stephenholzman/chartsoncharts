---
layout: post
title: Basic Responsive Chart Method Using D3
description: "Walkthrough of how you might code a responsive Axis using D3"
modified: 2016-04-04
tags: [D3, Responsive Design]
categories: [Tutorials]
author: "Stephen Holzman"
image: "responsiveTeaser.png"
---

Coming up with contingency plans for different display dimensions in D3 can get ugly. My recent charts all adjust for screen size, but they also have to handle different modes and view options as selected by users. I've quickly realized the advantages of using well-planned functions for almost everything including establishing scales, adding elements to the DOM, and modifying elements of the DOM.

Ideally, you might make a chart using two lines of JavaScript.

{% highlight JavaScript %}

draw_chart();

d3.select(window).on("resize",resize_chart);

{% endhighlight %}

One line to add a chart to the DOM and another to handle what happens when windows resize. For this example, these two lines of code are joined by 8 functions. Each function has a prefix that describes how it fits in with the bigger picture.

* **"calc"** functions set variables to certain values, but do not interact with the DOM in any way.

* **"draw"** functions add new elements to the DOM and invoke the necessary "calc" and "update" functions to render the intended feature.

* **"update"** functions modify existing DOM elements and invoke necessary "calc" functions.

* **"resize"** functions handle what happens when the window dimensions change, whether someone flips their phone to landscape or a browser window is resized.

For simplicity, this example goes over how I would set this up for a chart wrapper and x-Axis in depth. It certainly can and should be extended to all features in a responsive chart.

<center><h2>HTML Setup</h2></center>

{% highlight HTML %}
<!DOCTYPE html>
<meta charset="utf-8"/>
<meta name="HandheldFriendly" content="True">
<meta name="MobileOptimized" content="320">
<meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, maximum-scale=1.0, user-scalable=no">

<link rel="stylesheet" href="style.css" type="text/css" media="screen"/>

<script src="/assets/d3/d3.min.js"></script>

<div id="container"></div>
{% endhighlight %}

<center><h2>style.css</h2></center>
{% highlight CSS %}
#container{
  width:100%;
  height:100px;
}
.axis path, .axis line{
  fill: none;
  stroke: #000;
}
{% endhighlight %}

<center><h2>Function Requirements</h2></center>

These functions are written under the assumption that the chart will eventually be embedded in an iframe and does not need to interact with other charts or JavaScript on the main page. Even though I control both the iframe and the D3 visualization on this blog, I want whoever the theoretical frontend developer or content manager controlling the iframe is to have final say over the dimensions of the chart purely by setting the iframe width and height. The chart will adapt to their requirements. It should be easy for clients or team members to use the products of the visualization developer with minimal additional consulting or modifications.

The functions should behave consistently across all chart elements. Stick to the naming conventions. Additionally, stylistic choices should only be declared **in one place**. In many existing examples of responsive D3 design--and most of my previous projects-- the resize function restates lines of code. Ctrl + F should only find a single match for "width =". Changing it from 85% of window.innerWidth to 75% of window.innerWidth should only require a click and two keystrokes.

<center><h2>Going Through the Functions From Top to Bottom</h2></center>

<h3>draw_chart</h3>

{% highlight JavaScript %}

var draw_chart = function(){

  calc_dimensions();

  chart = d3.select("#container")
    .append("svg")

  update_chartAttr();

  draw_xAxis();

}

{% endhighlight %}

The first of two main "ideal" functions from the top of the post. The dimensions of the plot are calculated as defined in calc_dimensioins, an svg is appended to our container div, the attributes of the appended svg are updated by update_chartAttr, and then the x-Axis is added by draw_xAxis.

<h3>resize_chart</h3>

{% highlight JavaScript %}

var resize_chart = function(){

  calc_dimensions();

  update_chartAttr();

  update_xAxisAttr();

}

{% endhighlight %}

The second of the "ideal" functions. Still high level, we simply want to calculate the new dimensions and update each chart feature. The main benefit of this entire approach is just how easy it is to create the resize function.

<h3>draw_xAxis</h3>

{% highlight JavaScript %}

var draw_xAxis = function(){

  xAxisG = chart.append("g");

  update_xAxisAttr();

}

{% endhighlight %}

Similar to draw_chart, but simpler.

<h3>calc_dimensions</h3>

{% highlight JavaScript %}
var calc_dimensions = function(){

  margin = {top: 0, left: 100, bottom: 30, right: 100};

  width = window.innerWidth - margin.left - margin.right;

  height = 100;

}
{% endhighlight %}

If you are new to designing responsive charts, window.innerWidth and window.innerHeight are workhorse properties that enable responsive JavaScript code. Margins, chart width, and chart height are calculated. Width is the main variable that needs to be kept updated for this example.

<h3>update_chartAttr</h3>

{% highlight JavaScript %}
var update_chartAttr = function(){

  chartAttr = chart
    .attr("id","chart0")
    .attr("width",width+margin.left+margin.right)
    .attr("height",height)
    .style("position","fixed")

}

{% endhighlight %}

<h3>update_xAxisAttr</h3>

{% highlight JavaScript %}

var update_xAxisAttr = function(){

  calc_xScale();
  calc_xAxis();

  xAxisAttr = xAxisG
    .attr("id","xAxis")
    .attr("class","x axis")
    .attr("transform", "translate("+ margin.left + "," + height + ")")
    .call(xAxis);

}

{% endhighlight %}

The update functions modify existing DOM elements. Calling them after calc_dimensions will make sure that all widths, transforms, and other attributes or styles are updated. I also use update functions to initiate attributes and styles in draw functions.

<h3>calc_xScale</h3>

{% highlight JavaScript %}

var calc_xScale = function(){

  xScale = d3.scale.linear()
    .range([0, width])
    .domain([0, 400])

}

{% endhighlight %}

<h3>calc_xAxis</h3>

{% highlight JavaScript %}

var calc_xAxis = function(){

  xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("top")
    .ticks(8)

}

{% endhighlight %}

I split xScale and xAxis into their own functions for completeness even though you would rarely call one without the other. These setup everything that the draw_xAxis function needs to work.

<center><h2>Results</h2></center>

The result from the above code is an x-Axis with a width that adjusts to the width available. Viewing it just below or <a href="/assets/interactives/responsive/example1.html" target="_blank">in another window</a>, play around with it to see how it responds instantly to adjustments. If you're viewing on mobile, rotate your screen to change the orientation. You might also notice that the tick labels overlap when the width is low...

<div position="relative" padding-bottom="56%" height="0px" overflow="hidden" align="center">
<iframe src="/assets/interactives/responsive/example1.html" frameborder="0" position="absolute" top="0px" left="0px" width="100%" scrolling="no"> </iframe>
</div>

There are a few strategies you might use to improve the clarity of the chart at different screen sizes. You could change the font size or hide things using CSS media queries, but the way the code is set up makes it extremely easy to make adjustments using JavaScript.

<h3>calc_xAxis v2</h3>

{% highlight JavaScript %}

var calc_xAxis = function(){

  if(window.innerWidth > 700){
    numberTicks = 8;
  }else if(window.innerWidth > 500){
    numberTicks = 4;  
  }else{
    numberTicks = 2;
  }

  xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("top")
    .ticks(numberTicks)

}

{% endhighlight %}

<div position="relative" padding-bottom="56%" height="0px" overflow="hidden" align="center">
<iframe src="/assets/interactives/responsive/example2.html" frameborder="0" position="absolute" top="0px" left="0px" width="100%" scrolling="no"> </iframe>
</div>

This modification to the calc_xAxis function should look very similar to the media query strategy, although the modifications happen in the same place where you dictate the relevant feature and JavaScript lets you be a bit more creative with how many ticks exist in the DOM. <a href="/assets/interactives/responsive/example2.html" target="_blank">Check it out in a fresh window</a>

I have personally found developing charts in this way to be much easier than trying to get CSS to cascade in the way you expect it to. The conditions apply when you first use draw_chart and whenever resize_chart is needed, and any modifications in logic happen in only one section of the code in one file. Easy maintenance is critical to working fast. Other coders you are working with can find exactly what piece of code causes a particular thing to happen easily and make an adjustment in that one section of code that trickles down to everywhere it needs to be.

Future chart code I share will be following this general system. While it's not quite at Grand Unified Theory of D3 level yet, I look forward to building on it and documenting everything here!
