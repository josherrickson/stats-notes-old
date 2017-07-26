<<dd_include: stata-header.txt >>

# `mixed` versus `xtreg`

In Stata, panel data (repeated measures) can be modeled using `mixed` (and its siblings e.g. `melogit`, `mepoisson`) or using the `xt` toolkit,
including `xtset` and `xtreg`.

This document is an attempt to show the equivalency of the models between the two commands. There will be slight differences due to the algorithms
used in the backend but the results should generally be equivalent.

# Data

We'll use the "nlswork" data

~~~~
<<dd_do>>
webuse nlswork, clear
desc
<</dd_do>>
~~~~
