---
layout: page
title: Age-Specific Fertility Rate Trends - Small Multiples
image:
  feature: abstract-5.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
comments: false
modified: 2014-12-24
author: "Stephen Holzman"
---
<style>
.transformer{
	display:none;
}
.line{
	stroke-width:1;
	fill-opacity:.2
}
#ob0line{
	stroke:#6464E2;
	fill:#6464E2;
}
#ob1line{
	stroke:#F75C5C;
	fill:#F75C5C;	
}
#ob2line{
	stroke:#C9C935;
	fill:#C9C935;
}
#ob3line{
	stroke:#35C9C9;
	fill:#35C9C9;
}
.axis, .label{
	font-family:arial;
}
.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.year-label{
	font-size:12px;
	font-family:arial;
}

nav ul li #countryH{
    text-align: left;
    width: 278px;
}
.countryselector{
	height:29px;
}

ul {
	margin:0px;
	padding:0px;
}
li {
	display:inline;
	float:left;
}
.tfr {
	padding: 5px;
}
.styled-select select {
   background: transparent;
   border: none;
   font-size: 14px;
   height: 29px;
   padding: 5px;
   width: 110%;
   cursor:pointer;
   background: url(arrow-01.png) no-repeat 85% 0;
   background-size: 29px 29px;
   -webkit-appearance:none;
}

.styled-select {
   height: 29px;
   overflow: hidden;
   width: 100%;

}
.controller_table{
	width:100%;
}
select{
	font-size: 16px;
	-webkit-appearance: none;
	-webkit-border-radius: 0px;
}
option{
	-webkit-appearance: none;
}
#ob0,.blue select,.blue select option{
	background-color:#E0E0F9;
	color:#6464E2;
}
.blue select:hover{
	background-color:#6464E2;
	color:#E0E0F9;
	-webkit-background-color:#6464E2;
	-webkit-color:#E0E0F9;
}

#ob1,.red select, .red select option{
	background-color:#FDDEDE;
	color:#F75C5C;
}
.red select:hover{
	background-color:#F75C5C;
	color:#FDDEDE;
}
#ob2,.yellow select,.yellow select option{
	background-color:#F4F4D7;
	color:#C9C935;
}
.yellow select:hover{
	background-color:#C9C935;
	color:#F4F4D7;
}

#ob3,.teal select,.teal select option{
	background-color:#D7F4F4;
	color:#35C9C9;
}
.teal select:hover{
	background-color:#35C9C9;
	color:#D7F4F4;
}

.align-left{
	text-align:left;
}
.align-right{
	text-align:right;
}
#headers{
	background-color:#2E2E2E;
    font-size:18px;
    font-family:"Arial";
    margin:0px;
    padding:0px;
    height:36px;
}
#CountrySelect{
	color:#fff;
	background-color:#2E2E2E;
    font-size:18px;
    font-family:"Arial";
    padding:5px;
}
nav {
    width: 100%;
}

nav ul {
    display: flex;
    flex-direction: row;
    height:29px;
}

nav ul li {
    list-style: none;
    flex-grow: 1;
}

nav ul li a {
    display: block;
    text-align: right;
    padding:0px;
    margin:0px;
    font-family:arial;
    font-size:14px;
}
#chart0wrapper #anim-wrapper{
	width:100%;
	overflow:hidden;
}
#modubtn{
	cursor:pointer;
	font-family:arial;
}
</style>
<center><h3>X: Age</h3></center>
<center><h3>Y: Age-Specific Fertility Rate</h3></center>
<center><div id="modubtn" class="btn">Show Every Year</div></center>
<div id="main-wrapper"></div>
<script src="d3.js"></script>
<script>
var modu = 5;
var chartsizeadjust = 1;
var target = "#main-wrapper";
var currentyear = 1947;
var id = "country_controller";
d3.select("#modubtn")
	.on("click",function(){
		if (modu===5){
			modu = 1;
			d3.select(this).text("Show Every Five");
		}else{
			modu = 5;
			d3.select(this).text("Show Every Year");
		};
		d3.selectAll(".chart").remove();
		smallmultiples(globaldata);
	});


//Data variables to include in the table-controller
var variables = {
	"CountrySelect":{
		"title":"Select Countries Below",
		"smalltitle":"Country",
		"type":"select",
		"align":"align-left"
	}/*,
	"TotalFertilityRate":{
		"title":"Total Fertility Rate",
		"smalltitle":"TFR",
		"type":"stat",
		"align":"align-right",
		"get":"fertilityrates"
	},
	"MedianAgeFirstBirth":{
		"title":"Median Age at First Birth",
		"smalltitle":"MAFB",
		"type":"stat",
		"align":"align-right"
	}*/
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
};


var controller_table = function(target,variables,observations,id,data){

	//
	var table = d3.select(target).append("div")
										.attr("id",id)
										.attr("class","controller_table");
	var headers = table.append("nav")
							.attr("id","headers")
							.append("ul");


	for (variable in variables){
		console.log(variable);
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
				console.log(observation);
				selector.on("change",function(){
					d3.selectAll(".chart").remove();
					var sel = document.getElementById(this.id);
					var opts = sel.options;
					var fullid = this.id;
					
					observations[fullid.slice(0,3)].code = opts[[this.selectedIndex][0]].getAttribute("code");
					observations[fullid.slice(0,3)].countryname = opts[[this.selectedIndex][0]].innerHTML;
					smallmultiples(data);

					
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

var calcchart = function(year){
	chart_id = "chart"+year,
	chart_dimensions = {"width":125, "height":175},
	chart_axisinfo = {"xdomain":[12,50],"ydomain":[0,.3],"xlabel":"Age","ylabel":"Births per Woman"};
}
calcchart(1947);
//d3.select(window).on('resize',calcchart());

var draw_2dchart = function(target,id,dimensions,axisinfo){

	//More setup for responsive chart
	var chartparameters = function(){
		margin = {top: 20, right:.07*dimensions.width,bottom: 30, left: 60},
		width = dimensions.width - margin.left - margin.right,
		height = dimensions.height - margin.top - margin.bottom;
		xScale = d3.scale.linear().range([0,width]);
		yScale = d3.scale.linear().range([height,0]);
		xAxis = d3.svg.axis()
					.scale(xScale)
					.tickValues([20,35,50])
					.orient("bottom");

		yAxis = d3.svg.axis()
					.scale(yScale)
					.tickValues([0,.1,.2,.3])
					.orient("left");

		xScale.domain(axisinfo.xdomain);
		yScale.domain(axisinfo.ydomain);
	};

	chartparameters();

	//Attach the chart svg
	var chartsvg = d3.select(target)
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
	/*
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
	*/
	//Chart animated resizing function, mostly recalculating based on pixels available
	var resizechart = function(){
		chart_dimensions = {"width":window.innerWidth*.9*chartsizeadjust, "height":window.innerHeight/2},

		margin = {top: 20, right:.07*dimensions.width,bottom: 60, left: 60},
		width = chart_dimensions.width - margin.left - margin.right;
		height = chart_dimensions.height - margin.top - margin.bottom;
		xScale.range([0, width]);
    	yScale.range([height, 0]);

		HorizAxis
			.transition()
			.duration(001)
			.call(xAxis)
			.attr("transform", "translate(0," + height + ")")

		VertAxis
			.transition()
			.duration(001)
			.call(yAxis)

		d3.select("#"+id+"svg")
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

	//d3.select(window).on('resize',resizechart);
};
//Same definitions as above
var draw_lines = function(observations,data,year,id){
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
			var chart = d3.select("#"+id+"g");

			line = d3.svg.line()
					.x(function(d) {return xScale(d.xvalue); })
					.y(function(d) {return yScale(d.yvalue); });

			getcoordinates(eval("observations."+observation+".code"),year,globaldata);

			d3.select("#"+eval("observations."+observation+".id")+"stat").text(getTotalFertilityRate(globaldata,eval("observations."+observation+".code"),year));
			var path = chart.append("path")
							.datum(collection)
							.attr("id",eval("observations."+observation+".id")+"line")
							.attr("class", "line "+eval("observations."+observation+".color"))
							.attr("d", line);
		}else if(eval("observations."+observation+".code")==="None"){
			d3.select("#"+eval("observations."+observation+".id")+"stat").text("NA")
		};
	};	

	yearLabel = 	d3.select("#chart"+year+"g").append("text")
					.attr("class","year-label")
					.attr("text-anchor","end")
					.attr("x",width)
					.attr("y",10)
					.text(year);

	console.log(currentyear);
};
var getboundaryyears = function(data){
	minyears = [],
	maxyears = [];

	countries = [];
	for(observation in observations){		
		countries.push(eval("observations."+observation+".code"));
	}

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
function smallmultiples(data){
	getboundaryyears(data)
	for (year = latestmin; year <earliestmax+1; year++){
		if(year%modu===0){
			calcchart(year);
			draw_2dchart(target,chart_id,chart_dimensions,chart_axisinfo);
			draw_lines(observations,data,year,chart_id);
		}
		
	}
}

d3.json("data/alldata.json", function(data) {
	globaldata = data;
	controller_table(target,variables,observations,id,data);
	smallmultiples(data);


});

</script>

