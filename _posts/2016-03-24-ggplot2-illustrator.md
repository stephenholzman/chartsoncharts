---
layout: post
title: Using R and Adobe Illustrator to Make Excellent Charts
description: "Learn the basics of using R, ggplot2, and Adobe Illustrator to make rad charts while staying sane."
modified: 2016-03-26
tags: [R, ggplot2, Illustrator, tutorial, Static Charts]
categories: [Tutorials]
author: "Stephen Holzman"
image: "unemploymentTeaser.png"
---
I recorded a tutorial on how I use R, ggplot2, and Illustrator to make static charts! The data comes from the Bureau of Labor Statistics API, so all you need is an internet connection and an Illustrator license to recreate this chart. The R Script is also included below the video.

<iframe width="560" height="315" src="https://www.youtube.com/embed/Sa2jQgTWShQ" frameborder="0" allowfullscreen> </iframe>

<center><h2>Final Chart</h2></center>

<figure>
  <a href="/images/UnemploymentByRaceSex-01.png"><img src="/images/UnemploymentByRaceSex-01.png" alt=""></a>
</figure>

<center><h2>R Code</h2></center>

{% highlight R %}
#Load libraries
library(blsAPI)
library(rjson)
library(dplyr)
library(ggplot2)

#Build request parameters for the BLS API
parameters <- list(
  "seriesid" = c("LNS14000004", "LNS14000005","LNS14000007","LNS14000008"),
  "startyear" = 2007,
  "endyear" = 2016
)

#Send the request, store the response
response <- blsAPI(parameters,2)

#Convert response json to R list
json <- fromJSON(response)

#Establish dimensions of matrix to store rates
totalMonths <- length(json$Results$series[[1]]$data)
totalSeries <- length(parameters$seriesid)

#Set up dataframe for graphing
df <- matrix(nrow=totalMonths,ncol=totalSeries+2)

#Go through results and assign rates/dates to proper matrix coordinate
seriesCount <- 1
for(series in json$Results$series){
  dateCount <- 1
  for(item in json$Results$series[[seriesCount]]$data){
    df[dateCount,5] <- as.Date(paste(item$year,"-",substr(item$period,2,3),"-","01",sep=""))
    df[dateCount,6] <- paste(item$year,"-",substr(item$period,2,3),"-","01",sep="")
    
    df[dateCount,seriesCount] <- as.numeric(item$value)
    dateCount <- dateCount + 1
  }
  seriesCount <- seriesCount + 1
}
#Name columns
colnames(df) <- c("WhiteMale","WhiteFemale","BlackMale","BlackFemale","Date","DateString")

#Convert to data frame
df <- data.frame(df)

#Sort by date
df <- arrange(df, Date)

#Make sure data types are numeric or dates
df$WhiteMale <- as.numeric(as.character(df$WhiteMale))
df$WhiteFemale <- as.numeric(as.character(df$WhiteFemale))
df$BlackMale <- as.numeric(as.character(df$BlackMale))
df$BlackFemale <- as.numeric(as.character(df$BlackFemale))

df$Date <- as.numeric(as.character(df$Date))
df$DateString <- as.Date(as.character(df$DateString))

#Plotting
p <- ggplot(df, aes(x = DateString))
p <- p + theme(panel.grid.major.x = element_blank(),
               panel.grid.minor.x = element_blank(),
               panel.grid.minor.y = element_blank(),
               panel.grid.major.y = element_line(colour = "#AAAAAA"),
               plot.margin = unit(c(1, 1, 1, 3), "lines"),
               axis.text = element_text(face = "bold", size = rel(1.3)),
               axis.ticks = element_line(colour = NULL),
               axis.ticks.y = element_blank(),
               axis.ticks.x = element_line(colour = "black", size = 2),
               axis.line = element_line(colour = "black", size = 1.5),
               axis.line.y = element_blank(),
               axis.title.y = element_text(size = rel(1.8), angle = 90),
               panel.background = element_rect(fill = 'white'))
p <- p + geom_path(aes(y = WhiteMale), colour = "#B1B1F0", size = 2) 
p <- p + geom_path(aes(y = WhiteFemale), colour = "#E4E49A", size = 2) 
p <- p + geom_path(aes(y = BlackMale), colour = "#FBADAD", size = 2) 
p <- p + geom_path(aes(y = BlackFemale), colour = "#9AE4E4", size = 2) 
p <- p + scale_x_date()
p <- p + scale_y_continuous(limits = c(0, 22),expand = c(0,0))
p <- p + xlab("")
p <- p + ylab("Unemployment Rate")
print(p)

#Save to PDF
pdf("/Volumes/Storage/UnemploymentByRace.pdf", width = 12, height = 6)
print(p)
dev.off()

{% endhighlight %}
