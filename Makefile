# Sourced from https://github.com/audy/make-rmarkdown/blob/master/Makefile

# run `make` to compile all html
# run `make filename.html` to compile one specifically.

# Added '' around *.Rmd to expand properly.
# https://forums.freebsd.org/threads/29885/
SOURCES=$(shell find . -name '*.*md')
TARGETStmp=$(SOURCES:.md=.html)
TARGETS=$(TARGETStmp:.Rmd=.html)

%.html: %.Rmd
	@echo "$< -> $@"
	@Rscript -e "rmarkdown::render('$<')"

# State MD file
%.html: %.md
	@echo "$< -> $@"
	/Applications/Stata/StataSE.app/Contents/MacOS/stata-se -b dyndoc '$<', replace nostop

default: $(TARGETS)

clean:
	@rm -rf ratpup*

clean-all: clean
	@rm -rf $(TARGETS)
