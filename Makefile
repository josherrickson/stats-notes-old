# Sourced from https://github.com/audy/make-rmarkdown/blob/master/Makefile

# run `make` to compile all html
# run `make filename.html` to compile one specifically.

# Added '' around *.Rmd to expand properly.
# https://forums.freebsd.org/threads/29885/
Rmd=$(shell find R -name *.Rmd | sed 's.R/..')
R_HTML=$(Rmd:.Rmd=.html)

md=$(shell find Stata -name *.md)
Stata_Rmd=$(md:.md=.Rmd)

html=$(shell find Stata -name *.md | sed 's.Stata/..')
Stata_HTML=$(html:.md=.html)

%.html: R/%.Rmd
	@echo "$< -> $@"
	@Rscript -e "rmarkdown::render('$<')"
	@mv R/$@ $@

# Stata MD file
Stata/%.Rmd: Stata/%.md
	@echo "$< -> $@"
	/Applications/Stata/StataSE.app/Contents/MacOS/stata-se -b 'dyndoc "$<", saving("$@") replace nostop'

%.html: Stata/%.Rmd
	@echo "$< -> $@"
	Rscript --vanilla fixRmd.R $<
	Rscript -e "rmarkdown::render('$<')"
	mv Stata/$@ $@


default: $(R_HTML) $(Stata_Rmd) $(Stata_HTML)

clean:
	@rm -rf R/ratpup* Stata/*.svg

clean-all: clean
	@rm -rf $(R_HTML) $(Stata_Rmd) $(Stata_HTML)

print-%  : ; @echo $* = $($*)
