d <- haven::read_dta("~/Desktop/tmp.dta")
d$group <- as.factor(d$group)

mod1 <- glm(outcome ~ sex + group + sex*group, data = d, family = binomial)

# margins
mean(predict(mod1, type = "response"))
mean(arm::invlogit(c[1] + c[2]*d$sex + c[3]*(d$group == 2) + c[4]*(d$group == 3) +
      c[5]*d$sex*(d$group == 2) + c[6]*d$sex*(d$group == 3)))


# margins sex
d2 <- d
d2$sex <- 0
mean(predict(mod1, newdata = d2, type = "response"))
d2$sex <- 1
mean(predict(mod1, newdata = d2, type = "response"))

# margins, atmeans
s <- table(d$sex)[2]/nrow(d)
g <- table(d$group)/nrow(d)
c <- mod1$coef

arm::invlogit(c[1] + c[2]*s + c[3]*g[2] + c[4]*g[3] + c[5]*s*g[2] + c[6]*s*g[3])

# margins sex, atmeans
arm::invlogit(c[1] + c[2]*0 + c[3]*g[2] + c[4]*g[3] + c[5]*0*g[2] + c[6]*0*g[3])


mod2 <- glm(outcome ~ sex + group + sex*group + age, data = d, family = binomial)

# margins, at(age = 40)
d2 <- d
d2$age <- 40
mean(predict(mod2, newdata = d2, type = "response"))

# margins if sex == 0, at(sex = (0 1))
d2 <- d[d$sex == 0,]
d2$sex <- 0
mean(predict(mod2, newdata = d2, type = "response"))
d2$sex <- 1
mean(predict(mod2, newdata = d2, type = "response"))
