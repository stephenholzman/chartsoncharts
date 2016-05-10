---
layout: post
title: Try Out COC Charts with the COCLIBRARY R Package
description: "All my static chart templates will be available in this R package"
modified: 2016-05-10
tags: [Software, R, Charts, Tools]
categories: [Software]
author: "Stephen Holzman"
---

I decided to make an R package to facilitate the reuse of charts I make for the blog and am going to develop it out in the open. Since I've settled on a style guide, a custom charting library helps avoid hunting down old scripts and copy pasting code all the time. You are welcome to use it, though be warned it will be entirely unstable as I settle on what options to make available and it comes as is.

It should be pretty easy to install. Make sure you have devtools already installed and run:

{% highlight R %}

library(devtools)
install_github('StephenHolzman/COCLIBRARY')

{% endhighlight %}

This page will be sparse for a while, but it will be updated to provide an example for each function as they are added. Charts are for now designed to be saved as a PNG to disk, not look at in R or export to PDF for edits in Illustrator.

<h3>basicMultiline Example</h3>

{% highlight R %}

library(COCLIBRARY)
library(reshape2)

df <- NULL
df$day <- c(1,2,3,4,5)
df$random1 <-c(10,20,30,24,12)
df$random2 <-c(33,45,27,18,10)
df$random3 <-c(23,12,42,4,15)
df$random4 <-c(15,0,37,24,12)
df$random5 <-c(32,15,7,18,30)
df$random6 <-c(28,12,2,14,15)
df$random7 <-c(18,20,39,14,12)
df$random8 <-c(3,42,7,18,20)
df$random9 <-c(21,2,42,14,15)

df <- data.frame(df)

dfmelt <- melt(df, id.vars=c("day"))

basicMultiline(data = dfmelt,
               xvar = "day",
               yvar = "value",
               colourvar = "variable",
               title = "Random Numbers",
               subtitle = "Completely Made Up",
               cite = "Source: Thin Air",
               author = "@StephenHolz",
               ylabel = "Y Scale",
               xlabel = "X Scale",
               ylimits = c(0,55),
               ybreaks = c(0, 10, 20, 30, 40, 50),
               ylabels = c("$0","$10","$20","$30","$40","$50"),
               path = "/Volumes/Storage/testnumeric.png"
)

{% endhighlight %}

<figure>
  <a href="/images/testmultiline.png"><img src="/images/testmultiline.png" alt=""></a>
</figure>

<h3>basicScatter Example</h3>

{% highlight R %}

library(COCLIBRARY)

df <- NULL
df$group <- c("group1","group1","group1","group2","group2","group2","group3","group3","group3")
df$random1 <-c(10,20,30,24,12,23,12,42,4)
df$random2 <-c(33,45,27,18,10,32,15,7,18)

df <- data.frame(df)

basicScatter(data = df,
               xvar = "random1",
               yvar = "random2",
               colourvar = "group",
               title = "Random Numbers",
               subtitle = "Completely Made Up",
               cite = "Source: Thin Air",
               author = "@StephenHolz",
               ylabel = "Y Scale",
               xlabel = "X Scale",
               ylimits = c(0,55),
               ybreaks = c(0, 10, 20, 30, 40, 50),
               ylabels = c("0","10","20","30","40","50"),
               path = "/Volumes/Storage/testscatter.png"
)

{% endhighlight %}

<figure>
  <a href="/images/testscatter.png"><img src="/images/testscatter.png" alt=""></a>
</figure>

<h3>basicBar Example</h3>

{% highlight R %}

library(COCLIBRARY)

df <- NULL
df$cat <- c("cat1","cat2","cat3","cat4","cat5")
df$value <-c(42,20,34,13,16)
df <- data.frame(df)

basicBar(data = df,
         xvar = "cat",
         yvar = "value",
         colourvar = NULL,
         stat = "identity",
         pos = "stack",
         flip = TRUE,
         title = "Random Numbers",
         subtitle = "Completely Made Up",
         cite = "Source: Thin Air",
         author = "@StephenHolz",
         ylabel = "Y Scale",
         xlabel = "X Scale",
         ylimits = c(0,55),
         ybreaks = c(0, 10, 20, 30, 40, 50),
         ylabels = c("$0","$10","$20","$30","$40","$50"),
         path = "/Volumes/Storage/testbasicbar.png"
)

{% endhighlight %}

<figure>
  <a href="/images/testbasicbar.png"><img src="/images/testbasicbar.png" alt=""></a>
</figure>

<h3>basicBar Example - Horizontal and Stacked</h3>

{% highlight R %}

library(COCLIBRARY)

df <- NULL
df$cat <- c("cat1","cat1","cat1","cat2","cat2","cat2","cat3","cat3","cat3","cat4","cat4","cat4","cat5","cat5","cat5")
df$value <-c(10,20,5,13,16,8,12,25,10,27,5,11,19,12,7)
df$group <- c("group1","group2","group3","group1","group2","group3","group1","group2","group4","group1","group2","group4","group1","group2","group3")
df <- data.frame(df)

basicBar(data = df,
               xvar = "cat",
               yvar = "value",
               colourvar = "group",
               stat = "identity",
               pos = "stack",
               flip = TRUE,
               title = "Random Numbers",
               subtitle = "Completely Made Up",
               cite = "Source: Thin Air",
               author = "@StephenHolz",
               ylabel = "Y Scale",
               xlabel = "X Scale",
               ylimits = c(0,55),
               ybreaks = c(0, 10, 20, 30, 40, 50),
               ylabels = c("$0","$10","$20","$30","$40","$50"),
               path = "/Volumes/Storage/testbar.png"
)

{% endhighlight %}

<figure>
  <a href="/images/testbar.png"><img src="/images/testbar.png" alt=""></a>
</figure>

<h3>basicBar Example - Vertical and Dodged</h3>

{% highlight R %}

library(COCLIBRARY)


df <- NULL
df$cat <- c("cat1","cat1","cat1","cat2","cat2","cat2","cat3","cat3","cat3","cat4","cat4","cat4","cat5","cat5","cat5")
df$value <-c(42,20,34,13,16,8,22,49,15,27,5,22,19,12,42)
df$group <- c("group1","group2","group3","group1","group2","group3","group1","group2","group4","group1","group2","group4","group1","group2","group3")
df <- data.frame(df)

basicBar(data = df,
         xvar = "cat",
         yvar = "value",
         colourvar = "group",
         stat = "identity",
         pos = "dodge",
         flip = FALSE,
         title = "Random Numbers",
         subtitle = "Completely Made Up",
         cite = "Source: Thin Air",
         author = "@StephenHolz",
         ylabel = "Y Scale",
         xlabel = "X Scale",
         ylimits = c(0,55),
         ybreaks = c(0, 10, 20, 30, 40, 50),
         ylabels = c("$0","$10","$20","$30","$40","$50"),
         path = "/Volumes/Storage/testcol.png"
)

{% endhighlight %}

<figure>
  <a href="/images/testcol.png"><img src="/images/testcol.png" alt=""></a>
</figure>
