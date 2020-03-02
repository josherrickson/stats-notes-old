sysuse auto, clear
gen highmpg = mpg > 20

regress price c.mpg##i.highmpg


margins, at(mpg = (15(5)40) highmpg = (0 1))
marginsplot, x(mpg)

margins, at(mpg = (15 20) highmpg = 0) at(mpg = (20(5)40) highmpg = 1)
marginsplot, x(mpg)

* We use at for both variables to ease getting the values used later
margins, at(mpg = (15(5)40) highmpg = (0 1)) post

* r(table) contains the marginal means as well as confidence bounds
matrix t = r(table)
matrix t = t'
svmat t, names(col)
* r(at) contains the values of mpg and highmpg used
matrix at = r(at)
* Need to rename to avoid conflicting with existing data - alternatively, clear
* existing data
matrix colnames at = margins_mpg margins_0highmpg margins_1highmpg
svmat at, names(col)

twoway (rcap ll ul margins_mpg if margins_mpg >= 20 & margins_1highmpg == 1, ///
          lcolor(maroon)) ///
       (rcap ll ul margins_mpg if margins_mpg <= 20  & margins_1highmpg == 0, ///
          lcolor(navy)) ///
       (connected b margins_mpg if margins_mpg >= 20 & margins_1highmpg == 1, ///
          mcolor(maroon) lcolor(maroon)) ///
       (connected b margins_mpg if margins_mpg <= 20  & margins_1highmpg == 0, ///
          mcolor(navy) lcolor(navy))
