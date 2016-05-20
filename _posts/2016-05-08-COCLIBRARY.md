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

This page will be sparse for a while, but it will be updated to provide an example for each function as they are added. Charts are for now designed to be saved as a PNG to disk, not look at in R or export to PDF for edits in Illustrator. Examples below use datasets included with ggplot2, which is of course a dependency of COCLIBRARY.

<h2>Basics and Aesthetics</h2>

Most function arguments should be strings or vectors. The most basic scatter plot you might make would be...

{% highlight R %}
library(COCLIBRARY)

basicScatter(
  data = iris,
  xvar = "Sepal.Width",
  yvar = "Sepal.Length",
  path = "~/Github/chartsoncharts/images/aesthetics00.png"
)
{% endhighlight %}

<center><figure>
  <a href="/images/aesthetics00.png"><img src="/images/aesthetics00.png" alt=""></a>
</figure></center>

The main point of this library is to streamline chart features I know every chart I make is going to include. To add titles and citations...

{% highlight R %}
basicScatter(
  data = iris,
  xvar = "Sepal.Width",
  yvar = "Sepal.Length",
  title = "Iris Dimensions",
  subtitle = "Sepal Width vs Height",
  cite = "Source: Iris Sample Data",
  author = "@StephenHolz",
  xtitle = "Sepal Width",
  ytitle = "Sepal Length",
  path = "~/Github/chartsoncharts/images/aesthetics01.png"
)
{% endhighlight %}

<center><figure>
  <a href="/images/aesthetics01.png"><img src="/images/aesthetics01.png" alt=""></a>
</figure></center>

Depending on the chart type, arguments can reference dataset variables for things like color or size.

{% highlight R %}
basicScatter(
  data = iris,
  xvar = "Sepal.Width",
  yvar = "Sepal.Length",
  colourvar = "Species",
  pointsize = "Petal.Length",
  title = "Iris Dimensions",
  subtitle = "Sepal Width vs Height, by Species and Petal Length",
  cite = "Source: Iris Sample Data",
  author = "@StephenHolz",
  xtitle = "Sepal Width",
  ytitle = "Sepal Length",
  path = "~/Github/chartsoncharts/images/aesthetics02.png"
)
{% endhighlight %}

<center><figure>
  <a href="/images/aesthetics02.png"><img src="/images/aesthetics02.png" alt=""></a>
</figure></center>

Custom colors can also be used for certain elements.

{% highlight R %}
basicScatter(
  data = iris,
  xvar = "Sepal.Width",
  yvar = "Sepal.Length",
  colourvar = "Species",
  title = "Iris Dimensions",
  subtitle = "Sepal Width vs Height by Species",
  cite = "Source: Iris Sample Data",
  author = "@StephenHolz",
  xtitle = "Sepal Width",
  ytitle = "Sepal Length",
  plotbackground = "#E3E3E3",
  headerbackground = "#E3E3E3",
  headerfontcol = "Black",
  footerbackgroun = "Navy",
  colpal = c("maroon","yellow","blue"),
  path = "~/Github/chartsoncharts/images/aesthetics03.png"
)
{% endhighlight %}

<center><figure>
  <a href="/images/aesthetics03.png"><img src="/images/aesthetics03.png" alt=""></a>
</figure></center>

You can also specify certain fonts and dimensions. The default is Arial 800x600px. I'm aware there are some problems with the default font on some systems that call "Arial" "TT Arial". You can patch that with this argument until I figure out a fix, or use something else entirely.

{% highlight R %}
basicScatter(
  data = iris,
  xvar = "Sepal.Width",
  yvar = "Sepal.Length",
  colourvar = "Species",
  title = "Iris Dimensions",
  subtitle = "Sepal Width vs Height, by Species and Petal Length",
  cite = "Source: Iris Sample Data",
  author = "@StephenHolz",
  xtitle = "Sepal Width",
  ytitle = "Sepal Length",
  width = 400,
  height = 400,
  fontfamily = "Impact",
  path = "~/Github/chartsoncharts/images/aesthetics04.png"
)
{% endhighlight %}

<center><figure>
  <a href="/images/aesthetics04.png"><img src="/images/aesthetics04.png" alt=""></a>
</figure></center>

Axis dimensions can also be customized. I suggest either letting it set to default or using each of the limits, breaks, and labels arguments. There is still a little wonkiness to iron out when you just use one, but you can always experiment and see if it works for you.

{% highlight R %}
basicScatter(
  data = iris,
  xvar = "Sepal.Width",
  xlimits = c(0,5),
  xbreaks = c(0,1,2,3,4,5),
  xlabels = c("0cm","1cm","2cm","3cm","4cm","5cm"),
  ylimits = c(0,9),
  ybreaks = c(0,2,4,6,8),
  ylabels = c("","","4cm","","8cm"),
  yvar = "Sepal.Length",
  colourvar = "Species",
  title = "Iris Dimensions",
  subtitle = "Sepal Width vs Height, by Species and Petal Length",
  cite = "Source: Iris Sample Data",
  author = "@StephenHolz",
  xtitle = "Sepal Width",
  ytitle = "Sepal Length",
  path = "~/Github/chartsoncharts/images/aesthetics05.png"
)
{% endhighlight %}

<center><figure>
  <a href="/images/aesthetics05.png"><img src="/images/aesthetics05.png" alt=""></a>
</figure></center>

<h2>Boxplot Examples</h2>

<h3>Horizontal Boxplot With Subgroups</h3>
{% highlight R %}

library(dplyr)

plotdata <- mpg %>%
  mutate(drive = replace(drv, drv=="f", "Front")) %>%
  mutate(drive = replace(drive, drv=="r", "Rear")) %>%
  mutate(drive = replace(drive, drv=="4", "4WD")) %>%
  as.data.frame()

basicBoxplot(data = plotdata,
             xvar = "class",
             yvar = "hwy",
             colourvar = "drive",
             title = "Vehicle Highway MPG Performance",
             subtitle = "By Vehicle Class and Drive Type",
             cite = "Source: mpg Sample Data",
             author = "@StephenHolz",
             ytitle = "Highway MPG",
             xtitle = "Vehicle Class",
             ylimits = c(0,50),
             ybreaks = c(0,10,20,30,40,50),
             xlabels = c("2-Seater","Compact","Midsize","Minivan","Pickup","Sub-Compact","SUV"),
             path = "~/Github/chartsoncharts/images/boxplotexample00.png",
             fontfamily = "Arial"
)

{% endhighlight %}

<center><figure>
  <a href="/images/boxplotexample00.png"><img src="/images/boxplotexample00.png" alt=""></a>
</figure></center>

<h3>Vertical Boxplot with Subgroups</h3>

{% highlight R %}
basicBoxplot(data = plotdata,
             xvar = "class",
             yvar = "hwy",
             colourvar = "drive",
             title = "Vehicle Highway MPG Performance",
             subtitle = "By Vehicle Class and Drive Type",
             cite = "Source: mpg Sample Data",
             author = "@StephenHolz",
             ytitle = "Highway MPG",
             xtitle = "Vehicle Class",
             ylimits = c(0,50),
             ybreaks = c(0,10,20,30,40,50),
             xlabels = c("2-Seater","Compact","Midsize","Minivan","Pickup","Sub-Compact","SUV"),
             path = "~/Github/chartsoncharts/images/boxplotexample01.png",
             fontfamily = "Arial",
             flip = FALSE
)
{% endhighlight %}

<center><figure>
  <a href="/images/boxplotexample01.png"><img src="/images/boxplotexample01.png" alt=""></a>
</figure></center>

<h3>Simple Boxplot</h3>

{% highlight R %}
basicBoxplot(data = plotdata,
             xvar = "class",
             yvar = "hwy",
             title = "Vehicle Highway MPG Performance",
             subtitle = "By Vehicle Class",
             cite = "Source: mpg Sample Data",
             author = "@StephenHolz",
             ytitle = "Highway MPG",
             xtitle = "Vehicle Class",
             ylimits = c(0,55),
             ybreaks = c(0,10,20,30,40,50),
             xlabels = c("2-Seater","Compact","Midsize","Minivan","Pickup","Sub-Compact","SUV"),
             path = "~/Github/chartsoncharts/images/boxplotexample02.png",
             fontfamily = "Arial"
)
{% endhighlight %}

<center><figure>
  <a href="/images/boxplotexample02.png"><img src="/images/boxplotexample02.png" alt=""></a>
</figure></center>

<h2>Bar Chart Examples</h2>

<h3>Simple Bar Chart</h3>

{% highlight R %}
df <- NULL
df$cat <- c("cat1","cat1","cat1","cat1","cat2","cat2","cat2","cat2","cat3","cat3","cat3","cat3","cat4","cat4","cat4","cat4","cat5","cat5","cat5","cat5")
df$value <-c(10,20,5,13,16,8,12,25,10,27,5,11,19,12,7,22,15,18,26,21)
df$group <- c("group1","group2","group3","group4","group1","group2","group3","group4","group1","group2","group3","group4","group1","group2","group3","group4","group1","group2","group3","group4")
df <- data.frame(df, stringsAsFactors = FALSE)

basicBar(data = df,
         xvar = "cat",
         yvar = "value",
         pos = "stack",
         stat = "identity",
         title = "Random Numbers",
         subtitle = "Completely Made Up",
         cite = "Source: Thin Air",
         author = "@StephenHolz",
         path = "~/Github/chartsoncharts/images/barexample00.png"
)
{% endhighlight %}

<center><figure>
  <a href="/images/barexample00.png"><img src="/images/barexample00.png" alt=""></a>
</figure></center>

<h3>Stacked Color Coded Bar Chart</h3>

{% highlight R %}
basicBar(data = df,
         xvar = "cat",
         yvar = "value",
         pos = "stack",
         stat = "identity",
         title = "Random Numbers",
         subtitle = "Completely Made Up",
         cite = "Source: Thin Air",
         author = "@StephenHolz",
         path = "~/Github/chartsoncharts/images/barexample00.png"
)
{% endhighlight %}

<center><figure>
  <a href="/images/barexample01.png"><img src="/images/barexample01.png" alt=""></a>
</figure></center>

<h3>Dodged Color Coded Bar Chart</h3>

{% highlight R %}
basicBar(data = df,
         xvar = "cat",
         yvar = "value",
         pos = "dodge",
         stat = "identity",
         title = "Random Numbers",
         subtitle = "Completely Made Up",
         cite = "Source: Thin Air",
         author = "@StephenHolz",
         path = "~/Github/chartsoncharts/images/barexample00.png"
)
{% endhighlight %}

<center><figure>
  <a href="/images/barexample02.png"><img src="/images/barexample02.png" alt=""></a>
</figure></center>

<h3>Dodged Color Coded Column Chart</h3>

{% highlight R %}
basicBar(data = df,
         xvar = "cat",
         yvar = "value",
         pos = "dodge",
         stat = "identity",
         title = "Random Numbers",
         subtitle = "Completely Made Up",
         cite = "Source: Thin Air",
         author = "@StephenHolz",
         path = "~/Github/chartsoncharts/images/barexample00.png"
)
{% endhighlight %}

<center><figure>
  <a href="/images/barexample03.png"><img src="/images/barexample03.png" alt=""></a>
</figure></center>

<h2>Multiline Chart Examples</h2>

{% highlight R %}
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
               ytitle = "Y Scale",
               xtitle = "X Scale",
               ylimits = c(0,55),
               ybreaks = c(0, 10, 20, 30, 40, 50),
               ylabels = c("$0","$10","$20","$30","$40","$50"),
               path = "~/Github/chartsoncharts/images/multiexample00.png",
)
{% endhighlight %}

<center><figure>
  <a href="/images/multiexample00.png"><img src="/images/multiexample00.png" alt=""></a>
</figure></center>