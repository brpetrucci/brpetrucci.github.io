---
permalink: /
title: "Bruno do Rosario Petrucci"
excerpt: "About me"
author_profile: true
redirect_from: 
  - /about/
  - /about.html
---

<p>I am a PhD candidate at the <a href="https://www.eeob.iastate.edu/">Ecology, Evolution, and Organismal Biology (EEOB)</a> department at <a href="https://iastate.edu">Iowa State University</a>, advised by Prof. <a href="https://phyloworks.org">Tracy Heath</a>. 
My research centers around the integration of fossils into phylogenetic methods, both in the realm of tree inference and phylogenetic comparative methods. 
I received my B.S. in Computational and Applied Mathematics from the <a href="https://www.uchicago.edu">University of Chicago</a>, with an honors thesis advised by Prof. <a href="https://geosci.uchicago.edu/people/michael-foote/">Michael Foote</a>, where I developed and tested a novel birth-death simulation package (see <a href="https://brpetrucci.github.io/software">Software</a>).
I also worked for a summer in the <a href="https://labmeme.github.io/aboutme/">Macroevolution and Macroecology Lab (LabMeMe)</a> at the <a href="https://www5.usp.br/english/institutional/">University of Sâo Paulo</a>, under Prof. Tiago Bosisio Quental, where the work that eventually became my honors thesis began.</p>

## Recent news

{% assign now = site.time | date: '%s' | plus: 0 %}
{% assign six_months_ago = now | minus: 15778800 %}
{% assign recent_posts = site.posts | slice: 0, 1 %}
{% if site.posts.size > 1 %}
  {% assign second_post_time = site.posts[1].date | date: '%s' | plus: 0 %}
  {% if second_post_time >= six_months_ago %}
    {% assign recent_posts = site.posts | slice: 0, 2 %}
  {% endif %}
{% endif %}

<ul>
{% for post in recent_posts %}
  <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a> ({{ post.date | date: "%B %-d, %Y" }})</li>
{% endfor %}
</ul>

See all posts on the <a href="{{ '/news/' | relative_url }}">News</a> page.
