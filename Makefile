
pdf: lhs
	pdflatex PLAI.tex

lhs:
	/Users/rbonifacio/Library/Haskell/bin/lhs2tex -o PLAI.tex PLAI.lhs
