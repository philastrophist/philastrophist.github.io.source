---
layout: archive
title: "CV"
permalink: /cv/
author_profile: true
redirect_from:
  - /resume
---

{% include base_path %}

Download cv [here](/latex/cv-shauncread.pdf)

# Summary
%FORMAT[summary][FILL] %%


# Research Interests
%FORMAT[interests][LIST] * **%name%**: %desc%


# Experience
%FORMAT[experience][LIST] ## %name% \n *%location%*, %start% - %end% \n %info% \n %output% \n %bullets%


# Education
%FORMAT[education][LIST] ## %qualification% \n *%location%*, %start% - %end% \n %notes%


# Affiliations
%FORMAT[affiliations][LIST] %0%, *%1%*


# Publications
  <ul>{% for post in site.publications %}
    {% include archive-single-cv.html %}
  {% endfor %}</ul>
  
  
# Submitted and in preparation
%FORMAT[unpublished][LIST] * *%title%*, %authors%


# Presentations
%FORMAT[presentations][LIST] * **%meeting%**, %location% \n *%organiser%* \n %what%