---
layout: post
title: On GIFs and Responsive Design in Dataviz
description: "GIFS are bad. Visualizations that adapt to audience and device are good."
modified: 2016-02-01
tags: [Responsive Design, Animated Charts, Interactive Charts, Small Multiples, GIFS]
categories: [Opinions]
author: "Stephen Holzman"
---
I started experimenting with the R package ggplot2 for the first time in August 2015, which turned out to be quite the gateway drug. A handful of GIF data <a href="https://www.reddit.com/r/dataisbeautiful/comments/3gckpr/1933_to_2100_usa_age_distribution_oc/" target="_blank">animations</a> <a href="https://www.reddit.com/r/dataisbeautiful/comments/3g1aow/how_usa_agespecific_fertility_rates_have_changed/" target="_blank">posted</a> to <a href="https://www.reddit.com/r/dataisbeautiful/comments/3gplje/usa_vs_japan_agespecific_fertility_rates_19472010/" target="_blank">reddit</a> <a href="https://www.reddit.com/r/dataisbeautiful/comments/3i2l8u/usa_individual_state_unemployment_rates_from_1976/" target="_blank">turned</a> out to be way more popular than I had anticipated.

While the general audience was mesmerized by "dancing jello blobs", the use of GIFs and animation in data visualization have some significant downsides that I was previously ignorant to. A few <a href="https://www.reddit.com/r/dataisbeautiful/comments/3ihcib/i_am_here_to_talk_about_the_science_behind/" target="_blank">AMAs</a> <a href="https://www.reddit.com/r/dataisbeautiful/comments/3j7y0e" target="_blank">with</a> <a href="https://www.reddit.com/r/dataisbeautiful/comments/3k3if4/hi_im_mike_bostock_creator_of_d3js_and_a_former/" target="_blank">established</a> <a href="https://www.reddit.com/r/dataisbeautiful/comments/3mp9r7/im_hadley_wickham_chief_scientist_at_rstudio_and/" target="_blank">figures</a> in the dataviz community were extremely helpful in pointing me to relevant <a href="http://www.cc.gatech.edu/~stasko/papers/infovis08-anim.pdf" target="_blank">readings</a> and ideas that improved my understanding of what battles are actually being fought when one creates an abstract visual representation of data.

Randal Olson even <a href="http://www.randalolson.com/2015/08/23/small-multiples-vs-animated-gifs-for-showing-changes-in-fertility-rates-over-time/" target="_blank">wrote an excellent article</a> comparing animated GIFs to small multiples using the same fertility data in response that persuaded me to join the fight against GIF files. 

>Although Stephen’s GIF is fun to watch — especially because the animation gives the appearance of waves rising and falling — I couldn’t help but be frustrated by the limitations of GIFs in data visualization. If we wanted to compare the fertility rates of 1980 and 2010, for example, we’d have to keep a mental snapshot of what the 1980 frame looked like for when the 2010 frame came around. Thus, comparisons of time points beyond a couple years are impossible with animated GIFs unless the viewer has photographic memory.
>
>--<cite>Randal Olson</cite>

<figure>
  <img src="/images/usa-vs-japan-fertility.gif" alt="">
  <figcaption>The GIF in question.</figcaption>
</figure>

He is spot on, and forget trying to compare two years for now. It was frustrating for me, **_the creator_** of the visualization to look at **_one_** specific year! How can someone not as familiar with the data be expected to gain useful information?

<a href="/images/giveup.gif">So I am giving up on GIFs.</a>

<h3>Responsive Design in Data Visualization</h3>

The damning quality of the GIF is lack of control, but I have not been as quick to abandon *interactive* animation. GIFs and animation were referred to as sort of the same thing in Olson's article and I want to unwrap them here.

What I valued about GIFs is that they are relatively easy to create and behave basically the same no matter what device is viewing them. Olson's point that small multiples are incredibly useful is true, but their utility is also minimized on the growing share of small devices used to access the internet. Even for a data literate audience not easily lulled by the charms of an animation, looking at 1-year or even 5-year small multiples of some of the fertility data on a 4-inch screen is nightmarish.

Responsive design has already been promoted from buzzword to core tenet among web developers. The optimal path forward for viz folk should be to think about visualization designs that adapt to audience and device just as much as we think about selecting charts appropriate for the data being visualized. I am aware this is not a revolutionary idea. It is practiced by most major news organizations and quite a few individuals, but there are many stragglers across blogs, governments, and other entities that treat mobile as an afterthought.

Part of the reason is time. Testing the first batch of responsive/interactive/animated *Charts On Charts* visualizations across computers, tablets, and phones in a variety of configurations has been just as much a test on my sanity. Transitioning away from GIFs but keeping animation meant learning some HTML, CSS, and JavaScript in addition to navigating Amazon Web Services and the <a href="https://jekyllrb.com/" target="_blank">Jekyll</a> static site generator.

Not everyone can handle all of that depending on what other obligations they have. There is still something to be said for the simplicity of uploading a GIF to imgur or a small multiples PNG that users just have to pinch-zoom. Taking down the barriers to creating adaptive visualizations means publishing more code examples, tutorials, and open source tools that decrease development time.

<h3>Age-Specific Fertility Rates v2.0</h3>

The biggest advantage with moving to JavaScript away from GIFs and PNGs is that there is now access to all other countries in the Human Fertility Database in one place, encouraging people to ask questions and explore the data. Hopefully this leads to higher engagement, gets people to stick around longer, and results in better overall comprehension. In addition, all the dimensions of the chart adapt to the number of pixels available on the device it is viewed on.

The paper first draft of the revised visualization presented small multiples for computers and tablets while giving the animation to phones based on <a href="http://www.w3schools.com/cssref/css3_pr_mediaquery.asp" target="_blank">media queries</a>. There would be toggle buttons that modify the chart to cycle through the animation mode, a two year comparison mode that included sliders but no play button, and a small multiples mode that displayed every year.

Anything more than about a 6 frame small multiples chart personally made me a little dizzy with the fertility data. Some important (but small) fluctuations I want to highlight can be difficult to compare across physical space, but easy to see in the animation. In this particular case, I am still in favor of animation.

There should be room for strategy adjustment when displaying changes in color or displaying changes in shape over time. Having read just a <a href="http://www.sciencedirect.com/science/article/pii/S1071581902910177" target="_blank">few</a> <a href="http://thecartofish.com/FishGoldsBatts2011.pdf" target="_blank">papers</a>, right now I am much more in favor of purging animation from choropleths than I am for relatively simple interactive line graphs. 

The current version of this visualization defaults to the animation and includes a link to open small multiples in another window. I need to improve my understanding of JavaScript scope and iframe styling to get it more elegant, but I think this does a good job of satisfying a wide variety of audiences for now and improves the overall utility without making the controls too complex.

<center> <h2>Historical Fertility Rates</h2> </center>
<div class="interactive" align="right">
<iframe src="/assets/interactives/HFD/fertility.html" frameborder="0"> </iframe>
</div>
<div align="right"><a href="http://www.humanfertility.org/cgi-bin/main.php" target="_blank">Source: Human Fertility Database (January 27, 2016)</a></div>

<div align="right"><a href="/assets/interactives/HFD/fertilitysmallmultiple.html" target="_blank">View Multiple Years at Once</a></div>

<h3>Moving Forward</h3>

My views are still being refined as I look into how engagement and comprehension interact with presentation styles, but I hope this contributes to the discussion in a positive way. Ultimately the next step I am looking into is designing an A/B test for use in the wild. Engagement and comprehension in the lab is one thing, but what happens when you don't have the complete attention of your audience?

If an interactive animation is fun enough that someone sticks around to read a long article about fertility rates of all things, my hypothesis is that comprehension of the topic will be higher than if they were to move on to the next piece of clickbait. Even if animation might be inferior to small multiples in isolation, charts are of course just one supplementary communication tool among many. They are a multi-use tool that can be used to advertise "boring" topics just as they can be used to educate people about them.

<a href="https://www.youtube.com/watch?v=jbkSRLYSojo" target="_blank">Sometimes an animation</a> can be so captivating it pushes someone to pursue advanced degrees and make life altering decisions in order to <a href="/" target="_blank">contribute to the conversation.</a> 

>I teach global health, and I know having the data is not enough. I have to show it in ways people both enjoy and understand.
>
>--<cite>Hans Rosling</cite>

There is a full fertility rate trend post in the works for maybe next week, but for now you can explore the <a href="/code/fertility-code/">code</a> here. Let me know if you have thoughts on using animated charts effectively or if you think they belong with 3d pie charts! I promise to keep an open mind.



