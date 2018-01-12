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
first model can be fit lineally (because \\(\nu\_i\\) is constant and folds into the intercept).

## Assumptions

There is one key different assumption between the models:

The random effects model assumes that unobservable variables are uncorrelated with other covariates. The other models don't.

The between effects and random effects models assume that \\(\nu\_i\\) and \\(\overline{x}\_i\\) are uncorrelated (individual intercepts are
independent of predictors).

# `xtsum`: Estimating between/within/overall variance

The `xtsum` command can be used to estimate the variance of a variable within versus between.

~~~~
<<dd_do>>
xtsum ln_wage
<</dd_do>>
~~~~

It's an odd design choice to display the min/max for the between and within rows, but not the mean. In either case, we can obtain all these values
without `xt`. As a sidenote, "T-bar" represents the average number of measures per individual, or `N/n`.

## Overall variation

Easy:

~~~~
<<dd_do>>
summ ln_wage
<</dd_do>>
~~~~

## Within variation

Taking our cue from the notes in [the theory](#the-theory), to obtain within variation we will center the variable by individual.

~~~~
<<dd_do>>
egen meanln_wage = mean(ln_wage), by(idcode)
gen cln_wage = ln_wage - meanln_wage
summ cln_wage
<</dd_do>>
~~~~

Note that the mean is 0 (within rounding error), as we'd expect. To get the mean/min/max back into the same scale as the raw data we can re-add the
overall mean to

~~~~
<<dd_do>>
egen overallmean = mean(ln_wage)
gen cln_wage2 = cln_wage + overallmean
summ cln_wage2
<</dd_do>>
~~~~

This works because each individual has mean of 0 or in the second case, `overallmean`, in either case, since the means are constant, we've removed any
between variance and isolated the within variance.

## Between variation

We simply collapse by id.

~~~~
<<dd_do>>
preserve
collapse (mean) ln_wage, by(idcode)
summ ln_wage
restore
<</dd_do>>
~~~~

Doing this works because each subject now has a single observation, hence the within variance is identically 0, so the remaining variance is
between-variance.

# Fitting the models

Let's use the following as our model

```
ln_wage ~ grade + age + ttl_exp + tenure + not_smsa + south
```

## `xtreg, fe`: Fixed Effect model (Within variance)

The fixed effects results are

~~~~
<<dd_do>>
xtreg ln_wage grade age ttl_exp tenure not_smsa south, fe
<</dd_do>>
~~~~

To replicate, let's center each variable by individual and fit a linear model

~~~~
<<dd_do>>
foreach v of varlist ln_wage grade age ttl_exp tenure not_smsa south {
	qui egen `v'_mean = mean(`v'), by(idcode)
	qui gen `v'_cen = `v' - `v'_mean
}
reg ln_wage_cen grade_cen age_cen ttl_exp_cen tenure_cen not_smsa_cen south_cen, noconstant
<</dd_do>>
~~~~

As I stated earlier, we do get slightly different results. However, the coefficients agree to three decimals.

`grade` is not estimated because it is time-invarying; within each individual it is constant.

`xtreg` reports 3 R-squared statistics; this is a within variance model so we can use that value (which agrees with the regression R-squared).

## `xtreg, be`: Between Effect model (Between variance)

The between effects results are

~~~~
<<dd_do>>
xtreg ln_wage grade age ttl_exp tenure not_smsa south, be
<</dd_do>>
~~~~

To replicate, collapse over `idcode` and run a regression:

~~~~
<<dd_do>>
preserve
collapse (mean) ln_wage grade age ttl_exp tenure not_smsa south, by(idcode)
reg ln_wage grade age ttl_exp tenure not_smsa south
restore
<</dd_do>>
~~~~

Again, the coefficients agree to three decimals and the between R-square agrees.

All predictors here are estimated; if we had any time-variant by individual-invariant predictors (e.g. time), they would not be estimable here.

## `xtreg, re`: Random Effect model (Both variances)

The random effects results are

~~~~
<<dd_do>>
xtreg ln_wage grade age ttl_exp tenure not_smsa south, re
<</dd_do>>
~~~~

Just fit a regular mixed model:

~~~~
<<dd_do>>
mixed ln_wage grade age ttl_exp tenure not_smsa south || idcode:
<</dd_do>>
~~~~

The results are very close; we can get even closer by fitting the `xtreg` model with the `mle` option, which uses a different estimation strategy.

~~~~
<<dd_do>>
xtreg ln_wage grade age ttl_exp tenure not_smsa south, re mle
<</dd_do>>
~~~~
