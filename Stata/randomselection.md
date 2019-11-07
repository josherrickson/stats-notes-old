~~~~
<<dd_ignore>>
---
title: Choosing a Random Sample
author: Josh Errickson
output:
  html_document:
    toc: yes
    toc_depth: 4
    toc_float: yes
---
<</dd_ignore>>
~~~~

A common task is to select a random subset of rows from your data set. This document discusses an easy way to do this, including sampling from subsamples.

^#^^#^ Data

We'll load up the "auto" data set and shrink it down substantially in order to be able to print out the results.

~~~~
<<dd_do>>
sysuse auto
keep make foreign
bysort foreign: gen row = _n
keep if row <= 4
drop row
list, sep(0)
<</dd_do>>
~~~~

^#^^#^ Simple Random Sample

Let's say we want to select 4 rows, as a simple random sample. That is, the probability of any row being included in the sample is equal.

First, we'll generate a random number per row. You can use any distribution you want; uniform or normal are common.

~~~~
<<dd_do: quietly>>
set seed 6
<</dd_do>>
~~~~

~~~~
<<dd_do>>
generate rand = rnormal()
list, sep(0)
<</dd_do>>
~~~~

`rnormal` takes in 2 optional arguments of a mean and standard devation; the defaults are 0 and 1 respectively.

If you prefer uniform, you call `generate rand = runiform(a, b)` where `a` and `b` are upper and lower bounds, e.g. `generate rand = runiform(0, 1)`.

Now we simply sort by this new variable.

~~~~
<<dd_do>>
sort rand
list, sep(0)
<</dd_do>>
~~~~

Finally, we can identify our sample.

~~~~
<<dd_do>>
gen insample = _n <= 4
list, sep(0)
<</dd_do>>
~~~~

Recall that `_n` refers to the current row number, so this is just flagging all rows 4 and below!

^#^^#^ Sample by Subgroup

Consider the sample we obtained above, and notice that we sampled 3 domestic cars and 2 foreign cars. Since it was a simple random sample, that split
is random; we could have just as easily obtained all foriegn cars or any other combination. Perhaps we want to force some balance, for example, that
our random sample is exactly 2 foreign and 2 domestic.

We'll generate a new random number first just as before.

~~~~
<<dd_do>>
drop rand insample
generate rand = rnormal()
list, sep(0)
<</dd_do>>
~~~~

Now when we sort, we'll sort by `foriegn` first.

~~~~
<<dd_do>>
sort foreign rand
list, sep(0)
<</dd_do>>
~~~~

So we have two separate randomly sorted list, sep(0)s here. To select a fixed number from each, we can use the `bysort` prefix.

~~~~
<<dd_do>>
bysort foreign (rand): gen rownumber = _n
gen insample = rownumber <= 2
list, sep(0)
<</dd_do>>
~~~~

We could have also enforced an unequal split in `foreign`:

~~~~
<<dd_do>>
gen insample2 = rownumber <= 3 if foreign == 0
replace insample2 = rownumber <= 1 if foreign == 1
list, sep(0)
<</dd_do>>
~~~~
