---
layout: archive
title: "Research"
permalink: /research/
author_profile: true
redirect_from:
  - /research
---

{% include base_path %}

I am interested in a broad array of questions spanning phylogenetics, systematics, paleontology, and macroevolution.
The unifying theme of my research is developing, testing, improving, and applying computational methods leveraging fossil data in phylogenetics.
I am fascinated by what the past can tell us about the complex patterns that generated the astounding biodiversity around us, and how we can better use the methods and data at our disposal to learn about these patterns.
While most of my research has focused on phylogenetic comparative methods (PCM), I've recently become quite interested in methods of phylogenetic inference, especially those combining morphological and molecular data.
I'm question-oriented, and haven't hitched my wagon to any particular group in the past.
I have recently enjoyed delving deep into the systematics of Canidae, however, and hope to contribute much to our knowledge on this cuddly and fascinating group in the coming years.

# Integrating fossils into phylogenetic methods

The vast majority of the innumerable species that have called Earth home have gone extinct.
A very, very small percentage of those left remains that paleontologists can find, identify, and make available for the rest of us to study.
These fossils represent the only direct data on the past of life on Earth, and therefore provide researchers with the opportunity to test hypotheses about complex diversification patterns in deep-time.

## State-dependent diversification rate estimation with fossils
<center><p align="center">
  <img width="500" height="400" src="/images/sse.jpg" align="right">
</p></center>
Questions on the effect of traits on species diversification have been a mainstay of macroevolution since its inception.
[State-dependent speciation and extinction (SSE) models](https://revbayes.github.io/tutorials/sse/bisse-intro) provide a powerful framework to test such hypotheses.
Despite [some reservations on the model's false-positive rate](https://academic.oup.com/sysbio/article-abstract/64/2/340/1633695), SSE models remain one of the best options for researchers looking to understand how characters might have shaped the speciation dynamics of a group.
SSE analyses have historically used extant-only trees, making them not appropriate for the inference of trait-dependent extinction (unless [one is interested in tip-rates only](https://academic.oup.com/sysbio/article/72/1/50/6647869)), since the absence of fossil data makes the inference of past dynamics challenging.
Using my R package [paleobuddy](https://cran.r-project.org/web/packages/paleobuddy/index.html), I performed a simulation study to demonstrate that the inclusion of fossil data on the phylogeny in question allows for accurate inference of state-dependent extinction.
I will soon be applying this workflow to a complete canid phylogenetic tree to test whether hypercarnivory has affected extinction rates for that group. 

**Related publications**

- [Fossils improve extinction-rate estimates under state-dependent diversification models](https://royalsocietypublishing.org/doi/full/10.1098/rstb.2023.0313)
- [paleobuddy: An R package for flexible birth-death process simulation](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13996)

## Phylogenetic inference using stratigraphic ranges
<center><p align="center">
  <img width="500" height="400" src="/images/fbd_range.png" align="right">
</p></center>
The [fossilized birth-death process](https://revbayes.github.io/tutorials/fbd/fbd_specimen) has been the standard for combined-evidence analyses since its introduction in 2014.
However, the FBD specimen model (as it is now known) is not appropriate for phylogenetic inference in most paleontological data sets--since it is a taxonomy-independent model, it is impossible to include all morphological and stratigraphic data (including age uncertainty) for well-sampled species.
This leads researchers to implement imperfect workarounds, which could lead to [biased divergence times](https://www.frontiersin.org/journals/ecology-and-evolution/articles/10.3389/fevo.2020.00183/full).

The introduction of the [stratigraphic-range FBD (SRFBD) process](https://www.sciencedirect.com/science/article/pii/S002251931830119X) equipped researchers with a model that better accommodates the taxonomic structure of paleontological datasets, by allowing fossil data to be structured as stratigraphic ranges for each species. 
It also allows us to include all age information for each species, which could help solve some problematic topological placements.
To better understand the pros and cons of each FBD model, and to obtain a high-quality phylogenetic tree for PCM applications (see above), I am working on an application of SRFBD to a dataset of extant and extinct canids.
I will use both SRFBD and FBD specimen (with the oldest and youngest fossil occurrence for each species) to conduct combined-evidence analyses of Canidae, comparing the inferred topologies and divergence times with past studies analyzing the group.
I will also conduct a short simulation study to gain an objective understanding of the differences in accuracy of the different models.

**Related publications**

- In progress... but check out my talk at the 2025 Evolution Meeting!
