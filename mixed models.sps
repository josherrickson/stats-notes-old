* Encoding: UTF-8.
RECODE
  treatment
  ('High'=1)  ('Low'=2)  ('Control'=3)  INTO  treat .
EXECUTE .

VARIABLE LABEL treat "Treatment".
VALUE LABELS treat 1 "High" 2 "Low" 3 "Control".

* These two are identical. In the first, first screen was skipped. `litter` was added as an effect,
*  then chosen as a random effect. Random intercept was NOT included.

MIXED weight BY female litter treat WITH litsize
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=female treat female*treat litsize | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=litter | COVTYPE(VC).

* In this model, `litter` was chosen as "subject" in the first screen. Random Intercept was included
*  but not `litter`, and `litter` was included in "Subject groupings"

MIXED weight BY female treat WITH litsize
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=female treat female*treat litsize | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(litter) COVTYPE(VC).

* Both are requivalent to 
* lmer(weight ~ treatment*female + litsize + (1 | litter), data = rat, REML = TRUE)
