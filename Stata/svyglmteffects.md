~~~
<<dd_ignore>>
---
title: Stata: Mediation with svyset data
author: Josh Errickson
output:
  html_document:
    toc: yes
    toc_depth: 4
    toc_float: yes
---
<</dd_ignore>>
~~~~

Mediation models in Stata are fit with the `sem` command. `sem` does not support `svyset` data, so instead you use `gsem` (e.g. `svy: gsem
...`). However, `gsem` does not support `estat teffects` which calculates direct, indirect and total effects.

This document shows how to manually calculate these effects using `nlcom`.

Note that this is a case where all variables are continuous and all models are linear - we are only using `gsem` for it's support of `svy:`, not it's
support of GLMs. Indirect effects are a more complicated topic in those models which we do not address here. Additionally, we'll trust Stata to
compute standard errors rather than getting into any sticky issues of bootstrapping.

^#^ Standard Mediation

First, let's estimate the direct, indirect and total effects without the use of the survey design to show equivalence.

~~~~
<<dd_do>>
webuse gsem_multmed
<</dd_do>>
~~~~

The model we'll be fitting is

[mediation](path.png)

~~~~
<<dd_do>>
sem (perform <- satis support) (satis <- support)

estat teffects

sem, coeflegend

* main effect
estat teffects, noindirect nototal
nlcom _b[perform:support]

* Indirect effect
estat teffects, nodirect nototal
nlcom _b[perform:satis]*_b[satis:support]

* Total effect
estat teffects, nodirect noindirect
nlcom _b[perform:satis]*_b[satis:support] + _b[perform:support]




svyset branch [pweight = perform]

svy: gsem (perform <- satis support) (satis <- support)

* main effect
nlcom _b[perform:support]

* Indirect effect
nlcom _b[perform:satis]*_b[satis:support]

* Total effect
nlcom _b[perform:satis]*_b[satis:support] + _b[perform:support]

<</dd_do>>
~~~~
