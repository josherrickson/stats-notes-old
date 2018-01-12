# Sourced from https://github.com/audy/make-rmarkdown/blob/master/Makefile

# run `make` to compile all html
# run `make filename.html` to compile one specifically.

# Added '' around *.Rmd to expand properly.
# https://forums.freebsd.org/threads/29885/
Rmd=$(shell find R -name *.Rmd | sed 's.R/..')
R_HTML=$(Rmd:.Rmd=.html)
md=$(shell find Stata -name *.md | sed 's.Stata/..')
Stata_Rmd=$(md:.md=.Rmd)
Stata_HTML=$(md:.md=.html)

%.html: R/%.Rmd
	@echo "$< -> $@"
	@Rscript -e "rmarkdown::render('$<')"
	@mv R/$@ $@

# Stata MD file
%.Rmd: Stata/%.md
	@echo "$< -> $@"
	/Applications/Stata/StataSE.app/Contents/MacOS/stata-se -b 'dyndoc "$<", saving("Stata/$@") replace nostop'

%.html: Stata/%.Rmd
	@echo "$< -> $@"
	Rscript --vanilla fixRmd.R $<
	Rscript -e "rmarkdown::render('$<')"
	mv Stata/$@ $@


default: $(R_HTML) $(Stata_Rmd) $(Stata_HTML)

clean:
	@rm -rf ratpup*

clean-all: clean
	@rm -rf $(TARGETS)

print-%  : ; @echo $* = $($*)
