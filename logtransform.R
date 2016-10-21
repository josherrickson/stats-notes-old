rm(list = ls())
#install.packages("ISLR")
library(ISLR)
data(Hitters)

mod1 <- lm(log(Salary) ~ AtBat + Hits + HmRun + Years + League, data = Hitters)

newH <- data.frame(AtBat = sample(1:50, 1),
                   Hits = sample(1:30, 1),
                   HmRun = sample(1:10, 1),
                   Years = sample(1:10, 1),
                   League = c("A", "N"))

p <- predict(mod1, newdata = newH)
exp(p[2])/exp(p[1])
exp(mod1$coef["LeagueN"])
# "Group N is predicted to have `coef`% higher response on average compared to group A"


newH <- data.frame(AtBat = sample(1:50, 1),
                   Hits = sample(1:30, 1),
                   HmRun = c(40,50),
                   Years = sample(1:10, 1),
                   League = "A")

p <- predict(mod1, newdata = newH)
exp(p[2])/exp(p[1])
exp(10*mod1$coef["HmRun"])
# Linear change in X predicts percent change in Y.
# "An increase of 1 in HmRun predicts an average increase of `coef`% in response."



mod2 <- lm(Salary ~ AtBat + log(Hits) + HmRun + Years + League, data = Hitters)

newH <- data.frame(AtBat = sample(1:50, 1),
                   Hits = c(4, 4*1.2),
                   HmRun = sample(1:10, 1),
                   Years = sample(1:10, 1),
                   League = "A")

diff(predict(mod2, newdata = newH))
log(1.2)*mod2$coef[3]
# Percent change in X predicts linear change in Y.
# "An increase of 10% in Hits predicts an average incrase of `coef`*log(1.1) in response."



mod3 <- lm(log(Salary) ~ AtBat + log(Hits) + HmRun + Years + League, data = Hitters)

newH <- data.frame(AtBat = c(15,16),
                   Hits = sample(1:30, 1),
                   HmRun = sample(1:10, 1),
                   Years = sample(1:10, 1),
                   League = "A")

p <- predict(mod3, newdata = newH)
exp(p[2])/exp(p[1])
exp(mod3$coef["AtBat"])
# Un-logged coef has same interpretation as above.


newH <- data.frame(AtBat = sample(30:50, 1),
                   Hits = c(5, 5*1.1),
                   HmRun = sample(1:10, 1),
                   Years = sample(1:10, 1),
                   League = "A")

p <- predict(mod3, newdata = newH)
exp(p[2])/exp(p[1])
1.1^mod3$coef[3]
# Percent change in X predicts percent change in Y.
# "An increae of 10% in Hits predicts an average increase of 1.20^`coef`% in response."
