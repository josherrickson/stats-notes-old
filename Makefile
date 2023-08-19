dyndocs = $(wildcard *.dyndoc)
qmds = $(dyndocs:.dyndoc=.qmd)

.PHONY:default
default: $(qmds)
	quarto render

.PHONY:quarto-prerender
quarto-prerender: $(qmds)
	@echo > /dev/null

$(qmds): %.qmd: %.dyndoc
	/Applications/Stata/StataSE.app/Contents/MacOS/stata-se -b 'dyntext "$<", saving("$@") replace nostop'

.PHONY:open
open:
	open docs/index.html

.PHONY:preview
preview:
	quarto preview
