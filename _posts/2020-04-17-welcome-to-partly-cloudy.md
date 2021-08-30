---
layout: post
title: "Introducing Partly Cloudy"
date: 2020-04-17 11:21:49 -0500
tags: info blog
---

So called because I'll be writing posts about cloud-native patterns, practices and tools.

I chose to start by maintaining the site with [Jekyll](https://jekyllrb.com/), though I almost reconsidered upon discovering that the latest version of Jekyll [isn't fully supported](https://github.com/github/pages-gem/issues/651) for automatically-built GitHub Pages sites. That led me to write [a GitHub Action to build and publish the site](https://github.com/joshgav/joshgav.github.io/blob/master/.github/workflows/publish-site.yaml), inspired by [this post](https://sujaykundu.com/blog/post/deploy-jekyll-using-github-pages-and-github-actions). Feeling confident with that in hand, I pushed the first version and was pleasantly surprised to find the GitHub Pages *did* automatically build the site. Good thing too cause my custom Action originally pushed the built site to the `gh-pages` branch, which wouldn't work for a user's top-level user site - `joshgav.github.io` in my case.

I wasn't happy with the unpolished feel of the default `minima` theme, so I reviewed some others at [jekyllthemes.io](https://jekyllthemes.io/). That site offers Jekyll themes for $$ too; I'm not sure of its business model. In any case it helped me find a simple theme named "[moving](https://github.com/huangyz0918/moving)" which I liked. I installed it by editing my config files, testing locally, and pushing the changes to GitHub. But... my site didn't render and I received an email notification that GitHub Pages only works with [this subset of Jekyll themes](https://pages.github.com/themes/). Great, an opportunity to tweak and use the Action action!

So to use my chosen theme I went back and tweaked my action to listen for pushes to the `source` branch and push changes to the `master` branch, as required for the "top-level" GitHub Page. It seems to be working now.

Oh, if you're wondering I chose Jekyll cause it's an "elder statesman" of static site generation by now and has a community of users and plugin developers. That it's the official SSG for GitHub Pages also lent it favor.