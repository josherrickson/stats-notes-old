~~~
<<dd_ignore>>
---
title: Logistic Models and the Margins Command
author: Josh Errickson
output:
  html_document:
    toc: yes
    toc_depth: 4
    toc_float: yes
---
<</dd_ignore>>
~~~~

When looking at the results of a logistic model, there are several different measures of the relationship between the predictors and the probability
of a positive outcome that can be used to interpret the model:

- The odds ratios
- The log odds
- The odds
- Marginal probablities/percentages

If you are unclear which you are looking at, confusion can abound. This is doubly-confounded in Stata (in my opinion) where certain `margins` commands
will produce a different measure than perhaps expected.

^#^ Intercept only model

Let's start simple and consider a model with only an intercept. We'll use the "auto" data set, and fit a model predicting the probability of a car
being foreign made.

~~~~
<<dd_do>>
sysuse auto
logit foreign, nolog
logit, or
<</dd_do>>
~~~~

The default output from the `logit` command are the log odds, <<dd_display: %9.3g _b[_cons]>> and passing the `or` option gives the odds ratio of
<<dd_display: %9.3g exp(_b[_cons])>>. The conversion between these values is straightforward:

^$^^$^
    \textrm{log odds} = log(\textrm{odds})
^$^^$^
^$^^$^
    \textrm{odds} = \exp^{\textrm{log odds}}
^$^^$^


Let's backtrack to see how we arrive at those values.

First, let's look at the breakdown of foreign and domestic cars.

~~~~
<<dd_do>>
tab foreign
<</dd_do>>
~~~~

We see that ^$^P(\textrm{foreign})^$^ = <<dd_display: %9.4g 22/74>> and ^$^P(\textrm{domestic})^$^ = <<dd_display: %9.4g 52/74>>. We can convert these
probabilities into odds, using the formula

^$^^$^
    \textrm{Odds}(\textrm{foreign}) = \frac{P(\textrm{foreign})}{1 - P(\textrm{foreign})}.
^$^^$^

Therefore we can easily see that

^$^^$^
    \textrm{Odds}(\textrm{foreign}) = \frac{<<dd_display: %9.4g 22/74>>}{1 - <<dd_display: %9.4g 22/74>>} = <<dd_display: %9.4g 22/52>>
^$^^$^

and

^$^^$^
    \textrm{Odds}(\textrm{domestic}) = \frac{<<dd_display: %9.4g 52/74>>}{1 - <<dd_display: %9.4g 52/74>>} = <<dd_display: %9.4g 52/22>>.
^$^^$^

For completeness, to convert from odds to probability you can use

^$^^$^
    P(\textrm{foreign}) = \frac{\textrm{Odds}(\textrm{foreign})}{1 + \textrm{Odds}(\textrm{foreign})}.
^$^^$^

Note that the odds of a car being foreign is exactly the result we saw above from `logit, or`. So in a logistic model with only an intercept, the
coefficient on the intercept is the odds of a positive outcome.

Rather than calculate these manually, Stata can produce these automatically.

^$^P(\textrm{foreign})^$^:

~~~~
<<dd_do>>
margins
<</dd_do>>
~~~~

^$^\textrm{Odds}(\textrm{foreign})^$^:

~~~~
<<dd_do>>
margins, expression(exp(xb()))
<</dd_do>>
~~~~

The `expression(exp(xb()))` is a bit odd, but the easiest way to obtain what we need. Think of it as just saying "give me the odds".

^#^ A single binary predictor

In the intercept only example, we had no concept of an odds ratio. Let's add a fixed effect, in this case a binary predictor, which will require
interpreting an odds ratio.

~~~~
<<dd_do>>
gen highmileage = mpg > 25
label define highmileage 0 "Low Mileage" 1 "High Mileage"
label value highmileage highmileage
tab foreign highmileage
logit foreign i.highmileage, nolog
logit, or
<</dd_do>>
~~~~

^#^^#^ Probabilities

Let's look at the probabilities. Here we have conditional probabilities since we have a predictor. So we are interested in ^$^P(\textrm{foreign} |
\textrm{high mileage})^$^ and ^$^P(\textrm{foreign} | \textrm{low mileage})^$^.

From the table above, we can easily compute this:

~~~~
<<dd_do>>
tab foreign highmileage, col
<</dd_do>>
~~~~

We see ^$^P(\textrm{foreign} | \textrm{high mileage}) = <<dd_display: %9.4g 25/100>>^$^ and ^$^P(\textrm{foreign} | \textrm{low mileage}) = <<dd_display: %9.4g 7/14>>^$^.

We can also obtain these via `margins`^[Note that if you do not flag `highmileage` as a categorical with `i.`, you can use instead `margins,
over(highmileage)`. If you pass a continuous variable, it will compute the probability at each discrete value of the continuous variable.]:

~~~~
<<dd_do>>
margins highmileage
<</dd_do>>
~~~~

We can also test for equality between these percentages:

~~~~
<<dd_do>>
margins highmileage, pwcompare(pv)
<</dd_do>>
~~~~

^#^^#^ Odds

We can compute the odds using the formulas above, giving us


^$^^$^
    \textrm{Odds}(\textrm{foreign} | \textrm{high mileage}) = <<dd_display: %9.4g 7/7>>
^$^^$^

and

^$^^$^
    \textrm{Odds}(\textrm{foreign} | \textrm{low mileage}) = = <<dd_display: %9.4g 15/45>>.
^$^^$^

To obtain with `margins`, we again pass the `expression` option:

~~~~
<<dd_do>>
margins highmileage, expression(exp(xb()))
<</dd_do>>
~~~~

Note that we do *not* want to test if the odds are different using `pwcompare` as that's what the odds ratio is for!

^#^^#^ Odds ratio

The odds ratio is often very confusing to interpret, but is straightforward: An odds ratio predicts the number of positive outcomes we expect to see
for every negative outcome. So an odds ratio of 2 would mean for every domestic car, we'd expect to see 2 foreign cars. An odds ratio of .25 would
mean for every domestic car, we'd expect .25 foreign cars - or, for every 4 domestic cars, we'd expect 1 foreign car (since .25 = 1/4).

The odds ratio is literally the ratio of the odds.

^$^^$^
    \textrm{OR}(\textrm{foreign} | \textrm{high mileage}) = \frac{\textrm{odds}(\textrm{foreign} | \textrm{high mileage})}{\textrm{odds}(\textrm{foreign} | \textrm{low mileage})} = 1/.333 = 3
^$^^$^

Looking at the regression results again:

~~~~
<<dd_do>>
logit, or
<</dd_do>>
~~~~

The intercept is ^$^\textrm{odds}(\textrm{foreign} | \textrm{low mileage})^$^, the odds of a positive outcome in the baseline group, and the
coefficient on `highmileage` is the odds ratio!

Note that we cannot use the `margins` command to obtain the odds ratio^[If I'm wrong, please let me know!]. Instead, we use `lincom`:

~~~~
<<dd_do>>
lincom _b[1.highmileage], or
<</dd_do>>
~~~~

(I obtained the `_b[1.highmileage]` name by running `logit, coeflegend` to obtain the legend.) Note the `or` option, without it we obtain the log
odds.

^#^ A categorical predictor

Moving from a binary predictor to a categorical predictor is fairly straightforward; instead of a single odds ratio, we have two.

~~~~
<<dd_do>>
gen pricecat = price < 7500
replace pricecat = 2 if price >= 7500 & price < 10000
replace pricecat = 3 if price >= 10000 & price < .
logit foreign i.pricecat, or nolog
<</dd_do>>
~~~~

^#^^#^ Probabilities

~~~~
<<dd_do>>
tab foreign pricecat, col
<</dd_do>>
~~~~

~~~~
<<dd_do>>
margins pricecat
<</dd_do>>
~~~~

^#^^#^ Odds

The intercept is the odds of a foreign car in `pricecat` 1, or .2881/.7119 = <<dd_display: %9.4g 17/42>>. We can obtain the odds of each `pricecat` in the typical way.

~~~~
<<dd_do>>
margins pricecat, expression(exp(xb()))
<</dd_do>>
~~~~

^#^^#^ Odds ratios

Finally, the two coefficients in the model are the odds ratios of being in `pricecat` 2 or 3 versus 1. Again we can use `lincom` to obtain these.

~~~~
<<dd_do>>
lincom _b[2.pricecat], or
lincom _b[3.pricecat], or
<</dd_do>>
~~~~

Note here that multiplying the odds ratios by the odds in `pricecat` 1 (the intercept) gives the odds in the other group. E.g. 3.705*.4047 = 1.5.

^#^ A continuous predictor

Now let's replace the categorical predictor with a continuous one. Again, most interpretations stay the same.

~~~~
<<dd_do>>
logit foreign headroom, or nolog
<</dd_do>>
~~~~

Now instead of talking about probability or odds in a level of a categorical predictor, it is instead at a specific level of headroom. The intercept
is the odds of having a positive outcome when the headroom is identically 0, which in this case, as is often the case, is not interesting.

^#^^#^ Probabilities

We cannot look at crosstabs as we did before the compute probabilities, but the margins command still works.

~~~~
<<dd_do>>
margins, at(headroom = (2.5 5))
<</dd_do>>
~~~~

These are the predicted probabilties of a positive outcome at the referenced levels of `headroom`, i.e. ^$^P(\textrm{foreign} | \textrm{headroom} =
2.5)^$^ and ^$^P(\textrm{foreign} | \textrm{headroom} = 5)^$^.

^#^^#^ Odds

We can directly compute the odds given the probabilities above, but it's easier to continue using `margins`.

~~~~
<<dd_do>>
margins, at(headroom = (2.5 5)) expression(exp(xb()))
<</dd_do>>
~~~~

^#^^#^ Odds ratio

The coefficient in the logistic regression is interpreted as the odds ratio when increasing headroom by 1. In other words, if we had a collection of
cars with headroom of ^$^x^$^ and magically change their headroom to ^$^x + 1^$^, we would expect for every one additional domestic car, we'd see
<<dd_display: %9.4f exp(_b[headroom])>> additional foreign cars.

We can obtain this odds ratio by again using `lincom`.

~~~~
<<dd_do>>
lincom _b[headroom], or
<</dd_do>>
~~~~

^#^ Interactions

Let's consider interactions now. We'll interact two binary variables for each.

~~~~
<<dd_do>>
gen highprice = price > 5000
label define highprice 0 "Low Price" 1 "High Price"
label value highprice highprice
logit foreign i.highprice##i.highmileage, or nolog
<</dd_do>>
~~~~

^#^^#^ Probabilities

Because we have two categorical predictors, we can return to looking at crosstabs as a way of obtaining probabilities. The `margins` call will also
return them.

~~~~
<<dd_do>>
table foreign highmileage highprice
margins highprice#highmileage
<</dd_do>>
~~~~

This is similar to the categorical predictor, where there are four groups. For example, low price and low mileage, 2 out of 25 cars are foreign, so
the probability is 2/25 = <<dd_display: %9.4g 2/25>>.

^#^^#^ Odds

~~~~
<<dd_do>>
margins highprice#highmileage, expression(exp(xb()))
<</dd_do>>
~~~~

If you look at the logistic results above, the baseline categories are low mileage and low price. So, as before, the intercept is the odds of a
foreign car in that subcategory, which we see here.

We do not obtain the odds for the other categories in the regression output.


^#^^#^ Odds ratios

The odds ratios reported in the regression output only present part of the story. Let's take a look at them again.

~~~~
<<dd_do>>
logit, or 
<</dd_do>>
~~~~

The coefficient on `highprice` is the odds ratio of being foreign between high price and low price cars, in the low mileage category.

^$^^$^
    \frac{\textrm{OR}(\textrm{foreign}|\textrm{high price, low mileage})}{\textrm{OR}(\textrm{foreign}|\textrm{low price, low mileage})}
^$^^$^

The coefficient on `highmileage` is the odds ratio of being foreign between high mileage and low mileage cars, in the low price category.

^$^^$^
    \frac{\textrm{OR}(\textrm{foreign}|\textrm{low price, high mileage})}{\textrm{OR}(\textrm{foreign}|\textrm{low price, low mileage})}
^$^^$^

The interaction can be interpreted in one of two ways.
