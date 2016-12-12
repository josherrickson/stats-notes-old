# Sourced from https://github.com/audy/make-rmarkdown/blob/master/Makefile

# run `make` to compile all html
# run `make filename.html` to compile one specifically.

# Added '' around *.Rmd to expand properly.
# https://forums.freebsd.org/threads/29885/
SOURCES=$(shell find . -name '*.Rmd')
TARGETS=$(SOURCES:%.Rmd=%.html)

%.html: %.Rmd
	@echo "$< -> $@"
	@Rscript -e "rmarkdown::render('$<')"

default: $(TARGETS)

clean:
	@rm -rf $(TARGETS)
	@rm -rf ratpup*
