---
layout: post
title:  "Introducing Cloud with a Meatball"
date:   2020-04-17 11:21:49 -0500
categories: info blog
---
# Introducing "Cloud with a Meatball"

So called because I'll be writing posts about cloud-native patterns, practices and tools and I can be a bit of a meatball sometimes.

I chose to start by maintaining the site with [Jekyll 4.0](https://jekyllrb.com/), though I almost reconsidered upon discovering that the latest version of Jekyll [isn't fully supported](https://github.com/github/pages-gem/issues/651) for automatically-built GitHub Pages sites. That led me to write [a GitHub Action to build and publish the site](https://github.com/joshgav/joshgav.github.io/blob/master/.github/workflows/publish-site.yaml), inspired by [this post](https://sujaykundu.com/blog/post/deploy-jekyll-using-github-pages-and-github-actions). Feeling confident with that in hand, I pushed the first version and was pleasantly surprised to find the GitHub Pages *did* automatically build the site. Good thing too cause the Action pushes the built site to the `gh-pages` branch, which doesn't work for a user's top-level user site (that is, `*.github.io`).

I chose Jekyll cause it's an "elder statesman" of static site generation by now and has a community of users and plugin developers. That it's the official SSG for GitHub Pages also lent it favor.
