---
layout: archive
title: "Publications"
author_profile: true
---

+Equal contributions; ++Correspondence; +++Co-correspondence

{% if author.googlescholar %}
  You can also find my articles on <u><a href="{{author.googlescholar}}">my Google Scholar profile</a>.</u>
{% endif %}

{% include base_path %}

{% for post in site.publications reversed %}
  {% include archive-single.html %}
{% endfor %}

