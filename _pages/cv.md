---
layout: archive
title: "CV"
permalink: /cv/
author_profile: false
redirect_from:
  - /resume
---

{% include base_path %}

{% assign cv_pdf = '/cv/brpetrucci_cv.pdf' | relative_url %}

<p><a href="{{ cv_pdf }}" download>Download PDF</a> · <a href="{{ cv_pdf }}" target="_blank" rel="noopener">Open in a new tab</a></p>

<object class="fitvidsignore" data="{{ cv_pdf }}" type="application/pdf" style="width: 100%; height: 90vh; border: 1px solid #ddd;">
  <p>Your browser can't display the PDF here. <a href="{{ cv_pdf }}">Click here to view my CV.</a></p>
</object>
