# Generic paper Makefile
#
# For usage hints, "make help"
#
#  To create a LaTeX diff against the hg "tip" revision, use the target
#  "diff" (or "viewdiff").
#  To use a revision other than "tip", speciff DIFF=x on the
#  make command line to choose the revision x.
#

# Verbosity
ifeq (${V},1)
Q:=
else
Q:=@
endif

.PHONY: all

GEN_DIR = ${PWD}/data/generated
BIBDIR     ?= /home/disy/lib/BibTeX:../../../bibtex:../bibtex
LaTeXEnv   = TEXINPUTS=".:/home/disy/lib/TeX:/home/disy/lib/ps:${TEXINPUTS}:"
BibTexEnv  = BIBINPUTS=".:${BIBDIR}:${BIBINPUTS}:"
BibFiles   = defs,combined,systems,fm,other

LaTeX      = ${LaTeXEnv} pdflatex -interaction=nonstopmode
# Uncomment the following for the "report" and "simple" templates
#LaTeX      = ${LaTeXEnv} lualatex -interaction=nonstopmode
LaTeXdiff  = ./tools/latexdiff
BibTeX     = ${BibTexEnv} bibtex
Fig2Eps    = fig2dev -L eps
Dia2Eps    = dia -t eps -e
AS         = $(shell which as)
CC         = $(shell which gcc)
GnuPlot	   = gnuplot
Inkscape   = $(shell which inkscape)
Eps2Pdf	   = epstopdf --outfile
PdfView	   = xpdf
Pdf2Ps	   = pdf2ps
RmCR       = tr -d '\r'
sed        = $(shell which sed)
Lpr 	   = lpr
mv	   = mv
awk	   = awk
R	   = R

Targets    = phd


# CONFIGURATION OPTIONS
# =====================

# Extra figures that aren't supplied as dia, gnuplot or fig sources
# (eg figures already supplied in PDF, or supplied in EPS).
# List with pdf extensions.
# Note that PDF files should be added to the repo with an additional -shipped extension,
# but should appear here with just the .pdf extension.
ModeSwRoot=all up
ModeSwFigs=$(patsubst %,imgs/mode-switch-%.pdf,$(ModeSwRoot))
xtraFigRoot= edf ipbench
ExtraFigs= $(patsubst %,imgs/%.pdf,$(ExtraFigRoot)) $(ModeSwFigs)
TexIncludes= $(wildcard data/generated/*.inc) $(wildcard *.tex) crit_includes micro_includes aes_includes
# For ACM SIG camera ready submission. This will only work if Target
# is a single identifier. You should then be able to use the "camera" target,
# after setting CamRoot appropriately. Answer "no" for re-making references.bib
# Set CamRoot as the filename root per publisher's instructions.
# Should be <paperno>-<lastname-of-first-author>
CamRoot    = <paperno>-<last>
CamDir	   = cameraready

# Any other stuff that may be needed

# END CONFIGURATION OPTIONS
# =========================

Optional = $(addsuffix -diff, $(Targets))
All = $(Targets) $(Optional)
Diffopts= #--type=BWUNDERLINE #-c .latexdiffconfig --append-safecmd="Comment"

Perf_Sources = $(wildcard imgs/*.perf)
Dia_Sources = $(wildcard imgs/*.dia)
Fig_Sources = $(wildcard imgs/*.fig)
Gnuplot_Sources = $(wildcard imgs/*.gnuplot)
#SVG_Sources = $(wildcard imgs/*.svg)
R_Sources = $(wildcard imgs/*.r)
Styles = $(wildcard *.sty)  $(wildcard *.cls)
Figures = $(Perf_Sources:.perf=.pdf) $(Dia_Sources:.dia=.pdf) $(Fig_Sources:.fig=.pdf) $(SVG_Sources:.svg=.pdf) $(Gnuplot_Sources:.gnuplot=.pdf)  $(R_Sources:.r=.pdf) $(ExtraFigs)

Pdf = $(addsuffix .pdf, $(Targets))
Bib = references.bib
Tex = $(addsuffix .tex, $(Targets))
Diff_Pdf = $(addsuffix .pdf, $(Optional))
CamTex = $(addsuffix .tex, $(CamDir)/$(CamRoot))
CamPdf = $(addsuffix .pdf, $(CamDir)/$(CamRoot))
CamPs = $(addsuffix .ps, $(CamDir)/$(CamRoot))
CamRef = $(addsuffix .ref, $(CamDir)/$(CamRoot))
CamBib = $(CamDir)/$(Bib)
CamImgs = $(CamDir)/imgs

.PHONY: FORCE

all: pdf
diff: diff_pdf
FORCE: pdf
ps: $(Ps)
pdf: $(Figures) $(TexIncludes) Makefile $(Pdf)
diff_pdf: $(Figures) Makefile $(Diff_Pdf)

%.pdf: %.perf tools/bargraph.pl
	@echo $< '->' $@
	${Q} ${BarGraph} -pdf $< > $@

%.pdf: %.eps
	@echo $< '->' $@
	${Q} ${Eps2Pdf} $@ $<

%.pdf: %.ps
	@echo $< '->' $@
	${Q} ${Eps2Pdf} $@ $<

%.eps: %.svg
	@echo $< '->' $@
	${Q} $(if ${Inkscape},,echo "You need inkscape installed to build $@" >&2; exit 1)
	${Q} ${Inkscape} -f $< -D -z -E $@ > /dev/null 2>&1

%.pdf: %.svg
	@echo $< '->' $@
	${Q} $(if ${Inkscape},,echo "You need inkscape installed to build $@" >&2; exit 1)
	${Q} ${Inkscape} -f $< -D -z -A $@ > /dev/null 2>&1

# This target allows you to add figures which have the extension .c_pp that
# correspond to .c sources. Your .c sources can use the lines '/*<*/' and
# '/*>*/' to surround parts of the source you don't want shown in your PDF.
# This allows you to write a .c file that can be compile-checked here and then
# remove extraneous lines for display.
%.c_pp: %.c
	@echo $< '->' $@
	${Q}$(if ${CC},${CC} -c "$<" -o /dev/null,)
	${Q}${sed} -e '/\/\*<\*\//,/\/\*>\*\//d' "$<" >"$@"

%.s_pp: %.s
	@echo $< '->' $@
	${Q}$(if ${AS},${AS} -c "$<" -o /dev/null,)
	${Q}${sed} -e '/\/\*<\*\//,/\/\*>\*\//d' "$<" >"$@"

%.eps: %.dia
	@echo $< '->' $@
	${Q} ${Dia2Eps} $@ $<

%.eps: %.fig
	@echo $< '->' $@
	${Q} ${Fig2Eps} $< $@

%.eps: %.gnuplot
	@echo $< '->' $@
	${Q} ${GnuPlot} $<

%.eps: %.r
	@echo $< '->' $@
	${Q} ${R} --vanilla < $<

%.pdf: %.pdf-shipped
	cp $< $@

view: pdf
	${Q}for i in $(Pdf); do \
		$(PdfView) $$i & \
	done

viewdiff: diff
	${Q}for i in $(Diff_Pdf); do \
		$(PdfView) $$i & \
	done

print: pdf
	${Q}for i in $(Pdf); do \
		$(Lpr) $$i \
	done

clean:
	rm -f *.aux *.toc *.bbl *.blg *.dvi *.log *.pstex* *.eps *.cb *.brf \
		*.rel *.idx *.out *.ps *-diff.* *.mps .log *.diff tmp.*
	rm -r data/generated

realclean: clean
	rm -f *~ *.pdf *.tgz $(Bib)

tar:	realclean
	( p=`pwd` && d=`basename "$$p"` && cd .. && \
	  tar cfz $$d.tgz $$d && \
	  mv $$d.tgz $$d )

help:
	@echo "Main targets: all diff camera view viewdiff print clean realclean tar"
	@echo "'make diff' will show changes to head revision"
	@echo "'make DIFF=<rev> diff' will show changes to revision <rev>"
	@echo "Avoid TeX \def with arguments, this breaks latexdiff (use \newcommand)"

# Below is for ACM SIG final submission.
# Reply "no" when asked to re-build references.
# Note this generates a superset of ACM SIG requirements, enough to build the paper
camera: ${Pdf}
	@echo 1>&2 "Answer \"no\" when asked to rebuild $(Bib)"
#	@echo "${Tex},${Bib},${Pdf} -> ${CamTex},${CamBib},${CamPdf}"
	${Q}set ${Pdf}; \
		if [ $$# -ne 1 ]; then \
			echo 1>&2 "Too many targets ($$*)!"; \
			exit $$#; \
		fi
	${Q}mkdir -p ${CamDir}
	${Q}touch ${CamTex} || \
		( echo 1>&2 'Did you set "CamRoot" in the Makefile?'; \
		  rm -f ${CamTex} ; rmdir ${CamDir} ; exit 1 )
	${Q}cp -p ${Tex} ${CamTex}
	${Q}cp -p ${Bib} ${CamBib}
	${Q}cp -p ${Pdf} ${CamPdf}
	${Q}mkdir -p ${CamImgs}
	${Q}cp -p ${Figures} ${CamImgs}
	${Q}${Pdf2Ps} ${CamPdf} ${CamPs}
	${Q}sed  < ${Tex} > ${CamRef} \
		-e '1,/^\\begin{thebibliography}/d' \
		-e '/\\end{thebibliography}/,$$d' \
		-e 's/{\\etalchar{+}}/+/' \
		-e 's/\\bibitem\[\([0-9A-Za-z+]*\)\].*/\1/' \
		-e 's/\\[()]//g' \
		-e 's/\\newblock//' \
		-e 's/~/ /g' \
		-e 's/\\mu/u/g' \
		-e 's/\\[a-z][a-z][a-z]*//g' \
		-e 's/[{}]//g' \
		-e 's/\\&/\&/g' \
		-e 's/--/-/g' \
		-e 's/[0-9]th/& /'
	${Q}pdffonts ${CamPdf} | grep 'Type ' | \
	if egrep -v 'Type 1|TrueType  *yes'; then \
	    echo 1>&2 'Type-2/3 fonts remaining!'; \
	else echo 1>&2 'Fonts check passed'; fi
	@echo 1>&2 "\n==============================================="
	@echo 1>&2 "A superset of all files needed for submission are in ${CamDir}/"
	@echo 1>&2 "${CamRef} is the references list for" \
		"pasting into the web submission form"
	@echo 1>&2 "For a buildable version copy required .sty/.cls files into ${CamDir}/"
	@echo 1>&2 "Consider compressing ${CamPs} before committing to repo"

##############################################################################

DIFF ?= tip

%-diff.dvi: %-diff.tex

%-diff.tex: %.tex FORCE
	@echo "====> Retrieving revision $(DIFF) of $<"
	hg cat -r $(DIFF) $<  > $(@:-diff.tex=-$(DIFF)-diff.tex)
	@echo "====> Creating diff of revision $(DIFF) of $<"
	$(LaTeXdiff) $(Diffopts) $(@:-diff.tex=-$(DIFF)-diff.tex) $< | \
	${RmCR} > $@

.PHONY: FORCE
FORCE:

# don't delete %.aux intermediates
.SECONDARY:

##############################################################################

Rerun = '(There were undefined (references|citations)|Rerun to get (cross-references|the bars) right)'
Rerun_Bib = 'No file.*\.bbl|Citation.*undefined'
Undefined = '((Reference|Citation).*undefined)|(Label.*multiply defined)'
Error = '^! '

# combine citation commands from all targets into tmp.aux, generate references.bib from this
$(Bib): $(addsuffix .tex, $(Targets))
	@echo "====> Parsing targets for references"
	@cat > .log </dev/null
	${Q}for i in $(Targets); do \
		$(LaTeX) $$i.tex >>.log; \
		cat $$i.aux | grep -e "\(citation\|bibdata\|bibstyle\)" | sed 's/bibdata{references}/bibdata{$(BibFiles)}/g' >> all_refs.aux; \
	done
	@echo "====> Removing duplicate bib entries";
	${Q}cat all_refs.aux | sort -u > tmp.aux;
	${Q}if [ -s references.aux ]; then \
		diff references.aux tmp.aux > references.diff 2> /dev/null; \
	else rm -f references.diff; \
	fi; true
	${Q}if [ -s references.diff ] && [ -e $(Bib) ]; then \
		echo "====> Changed references:"; \
		cat references.diff | grep "citation"; \
		echo -n "These will cause changes to $(Bib), do you want to rebuild this file? (yes/NO): "; \
		read rebuild_refs; \
	fi; \
	if [ "$$rebuild_refs" = "yes" ] || [ -s all_refs.aux -a \! -e $(Bib) ]; then \
		echo "====> Building $(Bib)"; \
		$(BibTexEnv) ./tools/bibexport.sh -t -o tmp.bib tmp.aux > .log 2>&1; \
		if grep -q 'error message' .log; then \
			cat .log; \
			exit 1; \
		fi; \
		: Clean out junk. Remove following command if you really want it in; \
		: Note: awkward expression because sed is different on Mac and Linux; \
		${sed} <tmp.bib > $(Bib) \
			-e 's/^ *isbn *= *{/  NOisbn = {/' \
			-e 's/^ *issn *= *{/  NOissn = {/' \
			-e 's/^ *doi *= *{/  NOdoi = {/' \
			-e 's/^ *editor *= *{/  NOeditor = {/'; \
		cp tmp.aux references.aux; \
	fi;
	${Q}rm -f all_refs.aux tmp.aux references.diff

%.pdf: %.tex $(TexIncludes) $(Bib) $(Figures) $(Styles) Makefile
	${Q}if ! test -e $*.bbl || test $(Bib) -nt $*.bbl; then rm -f $*.bbl; fi
	@echo "====> LaTeX first pass: $(<)"
	${Q}$(LaTeX) $< >.log || if egrep -q $(Error) $*.log ; then cat .log; rm $@; false ; fi
	${Q}makeglossaries $(basename $<) > .log
	${Q}if egrep -q $(Rerun_Bib) $*.log ; then echo "====> BibTex" && ( $(BibTeX) $* > .log || ( cat .log ; false ) ) && echo "====> LaTeX BibTeX pass" && $(LaTeX) >.log $< || if egrep -q $(Error) $*.log ; then cat .log; rm $@; false ; fi ; fi
	${Q}if egrep -q $(Rerun) $*.log ; then echo "====> LaTeX rerun" && $(LaTeX) >.log $<; fi
	${Q}if egrep -q $(Rerun) $*.log ; then echo "====> LaTeX rerun" && $(LaTeX) >.log $<; fi
	${Q}if egrep -q $(Rerun) $*.log ; then echo "====> LaTeX rerun" && $(LaTeX) >.log $<; fi
	@echo "====> Undefined references and citations in $(<):"
	@egrep -i $(Undefined) $*.log || echo "None."
	@echo "====> Dimensions:"
	@grep "dimension:" $*.log || echo "None."
	@texcount *.tex

##############################################################################
# Generate a list of FIXMEs
fixmes:
	${Q}for i in $(Tex); do \
		echo "FIXMEs in $$i:"; \
		nl -b a $$i | grep "FIXME{" | nl -b a; \
		echo -n "Total FIXMES: " && grep "FIXME{" $$i | wc -l; \
		echo; \
	done
#
# fetch data
BAMBOO=http://bamboo.keg.ertos.in.nicta.com.au/browse/
BASE=EDF-BB
UL=EDF-RB
RT=EDF-PB
CRIT=EDF-CB
AES=EDF-AB
RTSMP=EDF-PSMP
BSMP=EDF-BSMP
DIR=/latestSuccessful/artifact/shared/
RUMP_REDIS_TEST_NUMBER=30
PERF_BASE=EDF-BPP
PERF_RT=EDF-PPP
PERF_NUMBERS= 0 1 2 3 4 5 6
PLATS = tx1 sabre haswell rpi3 hikey32 hikey64 kzm ia32

# get the microbenchmark data, we run this for all platforms
define micro_raw_data
.PHONY: $1_micro_raw_data
$1_micro_raw_data:
	wget -O ${PWD}/data/baseline-$1.json ${BAMBOO}${BASE}${DIR}$2/results.json
	wget -O ${PWD}/data/rt-$1.json ${BAMBOO}${RT}${DIR}$2/results.json
	$(foreach var, $(PERF_NUMBERS), \
		wget -O ${PWD}/data/ipc-perf-$(var)-rt-$1.json ${BAMBOO}${PERF_RT}$(var)${DIR}$2/results.json;)
	$(foreach var, $(PERF_NUMBERS), \
		wget -O ${PWD}/data/ipc-perf-$(var)-baseline-$1.json ${BAMBOO}${PERF_BASE}$(var)${DIR}$2/results.json;)
endef

$(eval $(call micro_raw_data,haswell,x64-haswell3-results.json))
$(eval $(call micro_raw_data,sabre,Sabre-sabre-results.json))
$(eval $(call micro_raw_data,tk1,tk1-jetson-results.json))
$(eval $(call micro_raw_data,odroidxu,OdroidXU-odroid-xu-results.json))
$(eval $(call micro_raw_data,zynq7000,zynq7000-zc706-results.json))
$(eval $(call micro_raw_data,rpi3,rpi3-rpi3-results.json))
$(eval $(call micro_raw_data,hikey32,hikey32-hikey-results.json))
$(eval $(call micro_raw_data,hikey64,hikey64-hikey-results.json))
$(eval $(call micro_raw_data,tx1,tx1-jetson-tx1-family-results.json))
$(eval $(call micro_raw_data,kzm,kzm-kzm-results.json))
$(eval $(call micro_raw_data,ia32,ia32-haswell3-results.json))
micro_raw_data: $(PLATS:%=%_micro_raw_data)

# get the bigger benchmark data, we only run this on some platforms
define rest_raw_data
.PHONY: $1_rest_raw_data
$1_rest_raw_data:
	wget -O ${PWD}/data/aes-$1.json ${BAMBOO}${AES}${DIR}$2/results.json
	wget -O ${PWD}/data/criticality-$1.json ${BAMBOO}${CRIT}${DIR}$2/results.json
	wget -O ${PWD}/data/ul-$1.json ${BAMBOO}${UL}${DIR}$2/results.json
	wget -O ${PWD}/data/rt-smp-$1.json ${BAMBOO}${RTSMP}${DIR}$2/results.json
	wget -O ${PWD}/data/baseline-smp-$1.json ${BAMBOO}${BSMP}${DIR}$2/results.json
endef


$(eval $(call rest_raw_data,haswell,x64-haswell3-results.json))
$(eval $(call rest_raw_data,sabre,Sabre-sabre-results.json))

rest_raw_data: haswell_rest_raw_data sabre_rest_raw_data

RUMP_REDIS_FILES = $(wildcard data/redis/*.json)

data/generated/redis.dat: $(RUMP_REDIS_FILES) data/ycsb-results.py
	(cd data && ./ycsb-results.py --platform=seL4)

data/generated/bmk-redis.dat: $(RUMP_REDIS_FILES) data/ycsb-results.py
	(cd data && ./ycsb-results.py --platform=bmk)

data/generated/netbsd-redis.dat: $(RUMP_REDIS_FILES) data/ycsb-results.py
	(cd data && ./ycsb-results.py --platform=netbsd)

data/generated/linux-redis.dat: $(RUMP_REDIS_FILES) data/ycsb-results.py
	(cd data && ./ycsb-results.py --platform=linux --num_runs=3)

#
# data processing
#

# first the microbenchmark data
define process_micro_data
.$1_process_micro_data: data/json-to-data.py data/baseline-$1.json data/rt-$1.json $(wildcard data/ipc-perf-*-$1.json) data/ipc-perf.py
	@mkdir -p ${PWD}/data/generated
	@echo '==== generating $1 data'
	@python3 ${PWD}/data/json-to-data.py -b ${PWD}/data/baseline-$1.json -rt ${PWD}/data/rt-$1.json -a $1 > gen-$1.log || \
		(cat gen-$1.log; false)
	@python3 ${PWD}/data/ipc-perf.py -p $1 -o ${PWD}/data/generated/$1-ipc-perf.inc
	@touch $$@
endef

# process microbenchmark includes for each platform
$(foreach var,${PLATS},$(eval $(call process_micro_data,$(var))))

process_micro_data: $(PLATS:%=.%_process_micro_data)

# aes data data
define process_aes_data
.$1_process_aes_data: data/json-to-data.py data/aes-$1.json
	@mkdir -p ${PWD}/data/generated
	@echo '==== generating $1 aes data'
	@python3 ${PWD}/data/json-to-data.py -aes ${PWD}/data/aes-$1.json -a $1 > gen-aes-$1.log || \
		(cat gen-aes-$1.log; false)
	@touch $$@
endef

$(eval $(call process_aes_data,haswell))
$(eval $(call process_aes_data,sabre))

# crit data
define process_crit_data
$1_process_crit_data: data/json-to-data.py data/criticality-$1.json
	@mkdir -p ${PWD}/data/generated
	@echo '==== generating $1 crit data'
	@python3 ${PWD}/data/json-to-data.py -c ${PWD}/data/criticality-$1.json -a $1 > gen-crit-$1-rest.log || \
		(cat gen-crit-$1-rest.log; false)
endef

$(eval $(call process_crit_data,haswell))
$(eval $(call process_crit_data,sabre))

#
# latex includes
#

# microbenchmarks
define micro_includes
${GEN_DIR}/$1-fastpath-ipc-micro.inc: .$1_process_micro_data
${GEN_DIR}/$1-slowpath-ipc-micro.inc: .$1_process_micro_data
${GEN_DIR}/$1-active-slowpath-ipc-micro.inc: .$1_process_micro_data
${GEN_DIR}/$1-schedule-micro.inc: .$1_process_micro_data
${GEN_DIR}/$1-irq-micro.inc: .$1_process_micro_data
${GEN_DIR}/$1-ipc-perf.inc: .$1_process_micro_data
.$1_micro_includes: ${GEN_DIR}/$1-fastpath-ipc-micro.inc ${GEN_DIR}/$1-slowpath-ipc-micro.inc \
                   ${GEN_DIR}/$1-active-slowpath-ipc-micro.inc ${GEN_DIR}/$1-schedule-micro.inc \
				   ${GEN_DIR}/$1-irq-micro.inc ${GEN_DIR}/$1-ipc-perf.inc
endef

# generate micro includes for each platform
$(foreach var,${PLATS},$(eval $(call micro_includes,$(var))))

micro_includes: $(PLATS:%=.%_micro_includes)

# aes
define aes_includes
$1-aes.inc: .$1_process_aes_data
$1_aes_includes: $1-aes.inc
endef

$(eval $(call aes_includes,haswell))
$(eval $(call aes_includes,sabre))

aes_includes: sabre_aes_includes haswell_aes_includes

# criticality
define crit_includes
${GEN_DIR}/$1-down-hi-cold.dat: $1_process_crit_data
${GEN_DIR}/$1-down-hi-hot.dat: $1_process_crit_data
${GEN_DIR}/$1-down-lo-cold.dat: $1_process_crit_data
${GEN_DIR}/$1-down-lo-hot.dat: $1_process_crit_data
${GEN_DIR}/$1-up-hi-cold.dat: $1_process_crit_data
${GEN_DIR}/$1-up-hi-hot.dat: $1_process_crit_data
${GEN_DIR}/$1-up-lo-cold.dat: $1_process_crit_data
${GEN_DIR}/$1-up-lo-hot.dat: $1_process_crit_data
$1_crit_includes: ${GEN_DIR}/$1-down-hi-cold.dat ${GEN_DIR}/$1-down-hi-hot.dat \
	              ${GEN_DIR}/$1-down-lo-cold.dat ${GEN_DIR}/$1-down-lo-hot.dat \
                  ${GEN_DIR}/$1-up-hi-cold.dat ${GEN_DIR}/$1-up-hi-hot.dat \
				  ${GEN_DIR}/$1-up-lo-cold.dat ${GEN_DIR}/$1-up-lo-hot.dat
endef

$(eval $(call crit_includes,haswell))
$(eval $(call crit_includes,sabre))

crit_includes: haswell_crit_includes sabre_crit_includes

#
# gnuplot dat files
#

define aes_dat
${GEN_DIR}/$1-shared-aes-1000.dat: .$1_process_aes_data
${GEN_DIR}/$1-shared-aes-100.dat: .$1_process_aes_data
${GEN_DIR}/$1-shared-aes-10.dat: .$1_process_aes_data
endef

$(eval $(call .aes_dat,haswell))
$(eval $(call .aes_dat,sabre))

# images


imgs/aes-shared.eps: $(foreach plat,sabre haswell,$(foreach var,10 100 1000,${GEN_DIR}/$(plat)-$(var)-shared-aes.dat))

ModeSwEps= $(patsubst %.pdf,%.eps,$(ModeSwFigs))
$(ModeSwEps): crit_includes


ipbench.gnuplot:	data/generated/ipbench.dat
data/generated/ipbench.dat:	data/ipbench.csv data/ipbench_data.py
	@mkdir -p ${PWD}/data/generated
	@echo '====> generating ipbench data'
	@python3 ${PWD}/data/ipbench_data.py -i ${PWD}/data/ipbench.csv -u${PWD}/data/ipbench_util.csv -o ${PWD}/data/generated/ipbench.dat > gen-ipbench.log || \
		( cat gen-ipbench.log; false )

ulsched: data/ul-sabre.json data/ul-haswell.json data/sched_results.py
data/generated/sabre-edf-%.dat: data/ul-sabre.json data/sched_results.py
	@mkdir -p ${PWD}/data/generated
	@echo '====> generating sabre ulsched data'
	@python3 ${PWD}/data/sched_results.py -a sabre -i ${PWD}/data/ul-sabre.json -o ${PWD}/data/generated/ > gen-edf.log

data/generated/haswell-edf-%.dat: data/ul-haswell.json data/sched_results.py
data/generated/haswell-edf-%.dat: data/ul-haswell.json data/sched_results.py
	@mkdir -p ${PWD}/data/generated
	@echo '====> generating haswell ulsched data'
	@python3 ${PWD}/data/sched_results.py -a haswell -i ${PWD}/data/ul-haswell.json -o ${PWD}/data/generated/ > gen-edf.log



EdfRoot=haswell-edf-coop haswell-edf-preempt sabre-edf-coop sabre-edf-preempt
EdfFiles=$(patsubst %,data/generated/%.dat,$(EdfRoot))
imgs/edf.eps: $(EdfFiles) data/linux-edf.dat
imgs/redis.eps: data/generated/redis.dat
imgs/ipbench.eps: data/generated/ipbench.dat

define smp_stuff
${GEN_DIR}/smp-$1.dat: data/process_smp.py data/baseline-smp-$1.json data/rt-smp-$1.json
	@echo '===> generating $1 smp data'
	@python3 data/process_smp.py -o ${GEN_DIR} -p $1 -b ${PWD}/data/baseline-smp-$1.json -rt ${PWD}/data/rt-smp-$1.json
endef

$(eval $(call smp_stuff,haswell))
$(eval $(call smp_stuff,sabre))


imgs/smp.gnuplot: ${GEN_DIR}/smp-haswell.dat ${GEN_DIR}/smp-sabre.dat
imgs/smp.eps: imgs/smp.gnuplot ${GEN_DIR}/smp-haswell.dat ${GEN_DIR}/smp-sabre.dat
imgs/smp.pdf: imgs/smp.eps ${GEN_DIR}/smp-haswell.dat ${GEN_DIR}/smp-sabre.dat
