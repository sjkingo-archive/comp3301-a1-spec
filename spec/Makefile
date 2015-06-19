spec.pdf: spec.tex style.sty hypersetup.tex title.tex
	xelatex $< && xelatex $< && xelatex $<

.PHONY: clean
clean:
	rm -f *.aux *.log *.out *.toc *.pdf *.bak
