TEXROOTFILE=these
BIBFILE=bach.bib
BIBFILE1=bach.bib
BIBFILE2=ref.bib
TEXBASEFILES=$(shell ls *tex)
TARFILE=these.tar
TEXCOVER=cover
#TEXPUBLICATIONS=publications
DIR=manuscrit  			#directory where the files are located
DINTRO=11
FINTRO=14
DPART1=15
D1=17
F1=36
D2=37
F2=48
D3=49
F3=54
#FPART1=50
DPART2=55
D4=57
F4=66
D5=67
F5=72
D6=73
F6=92
D7=93
F7=110
D8=111
F8=120
#FPART2=118
DCCL=121
FCCL=124
DANNEXES=125
FANNEXEA=132
DANNEXEB=133
FANNEXEB=140
DANNEXEC=141
FANNEXES=144
DGLOSSAIRE=145
FGLOSSAIRE=146
DINDEX=1
FINDEX=90
DBIBLIO=147
FBIBLIO=154
ABSTRACT=155

default: thesis

#.PHONY: $(TEXROOTFILE)-pdf

#$(TEXROOTFILE)-pdf: $(TEXBASEFILES) $(BIBFILE)
#$(TEXROOTFILE)-pdf: $(TEXBASEFILES) $(BIBFILE1) $(BIBFILE2)
#	latexmk -pdf $(TEXROOTFILE).tex
#	rubber -df $(TEXROOTFILE).tex
#	echo $^
#	pdflatex $(TEXROOTFILE)
#	bibtex $(TEXROOTFILE)
#	makeindex $(TEXROOTFILE)
#	makeindex -s tlglo.ist -o $(TEXROOTFILE).gls $(TEXROOTFILE).glo
#	pdflatex $(TEXROOTFILE)
#	pdflatex $(TEXROOTFILE)
#	evince $(TEXROOTFILE).pdf
#publis: $(PUBLICATIONS).pdf
#
#$(PUBLICATIONS).pdf:
#	cd ./publications && latexmk -pdf $(TEXPUBLICATIONS).tex
#	cd ..

cover: $(COVER).pdf

$(COVER).pdf:
	cd ./cover && latexmk -pdf $(TEXCOVER).tex
	cd ..

thesis: $(TEXROOTFILE).pdf

$(TEXROOTFILE).pdf: $(TEXBASEFILES) $(BIBFILE1) $(BIBFILE2) $(COVER).pdf 
	latexmk -pdf $(TEXROOTFILE).tex
	echo $^

#$(TEXROOTFILE)-dvi: $(TEXBASEFILES) $(BIBFILE)
$(TEXROOTFILE).dvi: $(TEXBASEFILES) $(BIBFILE1) $(BIBFILE2)
	latex $(TEXROOTFILE)
	bibtex $(TEXROOTFILE)
	#makeindex $(TEXROOTFILE)
	#makeindex -s tlglo.ist -o $(TEXROOTFILE).gls $(TEXROOTFILE).glo
	latex $(TEXROOTFILE)
	latex $(TEXROOTFILE)

ps:
	-dvips $(TEXROOTFILE).dvi

pdf:
	ps2pdf $(TEXROOTFILE).ps

latest: thesis
	pdftk these.pdf output `date +%Y-%m-%d_%H%M%S`-these-JCBach.pdf
	#cp these.pdf `date +%Y-%m-%d_%H%M%S`-these-JCBach.pdf

valid: thesis
	pdftk these.pdf output these-valide.pdf

clean.cover:
	cd ./cover && rm -Rf *.log *.aux *~ *.toc *.bbl *.blg *.ps *.ind *.tgz \
	*.nav	*.out *.snm *.vrb auto *.fdb_latexmk *.fls *.mtc* *.flg *.glo *.idx \
	*.lof	*.maf *.dvi \ *.gls *.ilg *\#* 

#clean.publications:
#	cd ./publications && rm -Rf *.log *.aux *~ *.toc *.bbl *.blg *.ps *.ind *.tgz \
#	*.nav	*.out *.snm *.vrb auto *.fdb_latexmk *.fls *.mtc* *.flg *.glo *.idx \
#	*.lof	*.maf *.dvi \ *.gls *.ilg *\#* 
#

clean.thesis:
	-rm -Rf *.log *.aux *~ *.toc *.bbl *.blg *.ps *.ind *.tgz *.nav *.out *.snm \
	*.vrb auto *.fdb_latexmk *.fls *.mtc* *.flg *.glo *.idx *.lof *.maf *.dvi \
	*.gls *.ilg *\#* 
	-rm -Rf *-$(TEXROOTFILE)-JCBach.pdf

#clean.publications
clean:clean.cover clean.thesis
#	-rm -Rf *.log *.aux *~ *.toc *.bbl *.blg *.ps *.ind *.tgz *.nav *.out *.snm \
#	*.vrb auto *.fdb_latexmk *.fls *.mtc* *.flg *.glo *.idx *.lof *.maf *.dvi \
#	*.gls *.ilg  **/*.aux **/*.log **/*.flg **/*.fdb_latexmk **/*.fls *\#* 

clean.all: clean clean.export
	-rm -Rf $(TEXROOTFILE).pdf
	-rm -Rf cover/$(TEXCOVER).pdf

#	-rm -Rf publications/$(TEXPUBLICATIONS).pdf

clean.export:
	-rm -Rf *-export.pdf

tar:
	make clean
	(cd ..; tar cvzf $(TARFILE) $(DIR); mv $(TARFILE) $(DIR))

intro: thesis
	pdfjam these.pdf ${DINTRO}-${FINTRO} --outfile intro-export.pdf

ch1: thesis
	pdfjam these.pdf ${D1}-${F1} --outfile ch1-export.pdf

ch2: thesis
	pdfjam these.pdf ${D2}-${F2} --outfile ch2-export.pdf

ch3: thesis
	pdfjam these.pdf ${D3}-${F3} --outfile ch3-export.pdf

ch4: thesis
	pdfjam these.pdf ${D4}-${F4} --outfile ch4-export.pdf

ch5: thesis
	pdfjam these.pdf ${D5}-${F5} --outfile ch5-export.pdf

ch6: thesis
	pdfjam these.pdf ${D6}-${F6} --outfile ch6-export.pdf

ch7: thesis
	pdfjam these.pdf ${D7}-${F7} --outfile ch7-export.pdf

ch8: thesis
	pdfjam these.pdf ${D8}-${F8} --outfile ch8-export.pdf

ccl: thesis
	pdfjam these.pdf ${DCCL}-${FCCL} --outfile ccl-export.pdf

sota: thesis
	pdfjam these.pdf ${DPART1}-${F3} --outfile part1-sota-export.pdf

contrib: thesis
	pdfjam these.pdf ${DPART2}-${F8} --outfile part2-contrib-export.pdf

glossaire: thesis
	pdfjam these.pdf ${DGLOSSAIRE}-${DGLOSSAIRE} --outfile glossaire-export.pdf

biblio: thesis
	pdfjam these.pdf ${DBIBLIO}-${FBIBLIO} --outfile biblio-export.pdf

annexea: thesis
	pdfjam these.pdf ${DANNEXES}-${FANNEXEA} --outfile annexea-export.pdf

annexeb: thesis
	pdfjam these.pdf ${DANNEXEB}-${FANNEXES} --outfile annexeb-export.pdf

annexes: thesis
	pdfjam these.pdf ${DANNEXES}-${FANNEXES} --outfile annexes-export.pdf

abstract: thesis
	pdfjam these.pdf ${ABSTRACT}-${ABSTRACT} --outfile abstract-export.pdf

thx: thesis
	pdfjam these.pdf 3-3 --outfile remerciements-export.pdf

#intro #ch5 #ccl 
exportall: intro ch1 ch2 ch3 ch4 ch5 ch6 ch7 ch8 ccl sota contrib annexes glossaire biblio abstract thx

#test: thesis
#	pdfjam these.pdf 11-16 --outfile chtest.pdf
