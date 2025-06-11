---
layout: archive
title: "Software"
permalink: /software/
author_profile: true
---

{% include base_path %}

## Open-Source Projects

### [paleobuddy](https://github.com/brpetrucci/paleobuddy): Flexible simulations of birth-death-sampling models

paleobuddy is an R package to simulate phylogenetic trees and fossil records.
It allows for efficient simulation of a number of scenarios of interest for the validation of macroevolution software.

- Prioritizes computational efficiency in draws from complex birth-death-sampling distributions
- Written to allow for straightforward expansion by use of flexible forward-simulation framework
- Includes dependence on absolute age, species age, traits, and environmental variables for speciation, extinction, and fossil-sampling rate

> **Role**: Maintainer | **License**: GPL | **Current version**: 1.1.0    
> 🔗 View on [GitHub](https://github.com/brpetrucci/paleobuddy) or [CRAN](https://cran.r-project.org/web/packages/paleobuddy/index.html)

---

### [RevBayes](https://revbayes.github.io/): Bayesian phylogenetic inference using probabilistic graphical models and an interpreted language

<center><p align="center">
  <img width="100" height="80" src="/images/rev.png" align="right">
</p></center>

RevBayes is a C++-based software to perform Bayesian phylogenetic analyses.
It makes use of [probabilistic graphical models](https://academic.oup.com/sysbio/article/63/5/753/2847897) and an interpreted language (Rev, similar to R) to maximize flexibility and modularity.
In Spring and Summer of 2025, I was part of an [NSF POSE grant](https://www.nsf.gov/funding/opportunities/pose-pathways-enable-open-source-ecosystems) to make RevBayes more accessible to users, improve its testing suite and website, and investigate the most effective ways to garner user feedback.

- C++ backend makes for efficient and flexible object-oriented framework
- Includes a plethora of models of inference for phylogenetic trees, macroevolutionary rates, biogrography, traits etc.
- Its focus on modularity and highly active community makes for a package that is constantly improving and expanding
- Robust tutorials can aid with nearly any analysis setup

> **Role**: Contributor | **License**: GPL   
> 🔗 View on [GitHub](https://github.com/revbayes/revbayes)
