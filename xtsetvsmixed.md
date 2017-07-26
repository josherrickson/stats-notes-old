<<dd_include: stata-header.txt >>

# `mixed` versus `xtreg`

In Stata, panel data (repeated measures) can be modeled using `mixed` (and its siblings e.g. `melogit`, `mepoisson`) or using the `xt` toolkit,
including `xtset` and `xtreg`.

This document is an attempt to show the equivalency of the models between the two commands. There will be slight differences due to the algorithms
used in the backend but the results should generally be equivalent.

# Data

We'll use the "nlswork" data:

~~~~
<<dd_do>>
webuse nlswork, clear
desc
<</dd_do>>
~~~~

`idcode` represents each individual, data is measured over the years. Lets set it up using `xtset`:

~~~~
<<dd_do>>
xtset idcode
<</dd_do>>
~~~~

# Theory

Within the panel/`xt` framework, there are three separate models:

- `fe` or "fixed effects". This is modeling the within variation - Ignoring differences between individuals, is there a difference per values of
  time-varying variables?
- `be` or "between effects". This is modeling the between variation - Averaging across individuals (collapsing over time), is there a difference per
  values of subject-varying variables?
- `re` or "random effects". This generates a weighted average of the above two models.

Each is fitted via

```
xtreg <model>, fe
xtreg <model>, be
xtreg <model>, re
```

The short version of how to fit each model using `mixed` is:

- `fe`: By individual, center each \\(y\\) and \\(x\\) (hence each individual has an average value of 0, so the between variance is 0) and run a linear
  model with `reg`.
- `be`: Collapse over individual, and run a linear model with `reg`.
- `re`: A traditional mixed model with a random effect (this is random effect in the sense of a mixed model, not in the `xt` setting) for individual.

## The Math

Picture a typical mixed model setup:

\\[
    y\_{it} = \alpha + x\_{it}\beta + \nu\_i + \epsilon\_{it}.
\\]

Here \\(i\\) is an index for individuals, \\(t\\) is an index for time. \\(y\_{it}\\) and \\(x\_{it}\\) are some outcome and predictor which are both
time and individual varying. \\(\nu\_{i}\\) is an error associated with each individual and \\(\epsilon\_{it}\\) is an additional error per
observation.

If this model is true, then the following must be true:

\\[
    \overline{y}\_i = \alpha + \overline{x}\_i\beta + \nu\_i + \overline{\epsilon\_i}.
\\]

Each bar'd variable is average over each individual. In this model, \\(\nu\_i\\) and \\(\overline{\epsilon}\_i\\) are indistinguishable, so this is
just a linear model.

Since we have that both models are equivalent, if we difference them, we remain equivalent:

\\[
    (y\_{it} - \overline{y}\_i) = (x\_{it} - \overline{x}\_i)\beta + (\epsilon\_{it} - \overline{\epsilon}\_i).
\\]

Again, we have just a linear model.

Finally, the random effects model doesn't add much clarity, but it essentially is a weighted combination of the other two, with the weight being a
function of the variance of \\(\nu\_i\\) and \\(\epsilon\_i\\). If the variance of \\(\nu\_i\\) is 0, then there's no individual level effect and the
first model can be fit linearlly (because \\(\nu\_i\\) is constant and folds into the intercept).

## Assumptions

There is one key different assumption between the models:

The random effects model assumes that unobservable variables are uncorrelated with other covariates. The other models don't.

The between effects and random effects models assume that \\(\nu\_i\\) and \\(\overline{x}\_i\\) are uncorrelated (individual intercepts are
independent of predictors).
