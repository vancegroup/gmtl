# $Id: docbook.mk,v 1.1 2002-04-23 22:01:19 subatomic Exp $

.SUFFIXES: .html .xml .pdf .tex .fo .txt

XALAN_VERSION?=	20020214
SAXON_VERSION?=	6.5.1

DVIPDF?=	dvipdf
DVIPS?=		dvips
FOP?=		sh $(DOCBOOK_ROOT)/fop/fop.sh
JADE?=		openjade
JADEPROC?=	$(DOCBOOK_ROOT)/jadeproc.pl
JADETEX?=	$(TEX_BINDIR)/jadetex
PDFJADETEX?=	$(TEX_BINDIR)/pdfjadetex
PDFLATEX?=	$(TEX_BINDIR)/pdflatex
PDFTEX?=	$(TEX_BINDIR)/pdftex
RM=		rm -f
SAXON?=		$(DOCBOOK_ROOT)/saxon-$(SAXON_VERSION)/saxon.sh
TEX_DIR?=	$(DOCBOOK_ROOT)/TeX
TEX_BINDIR?=	$(TEX_DIR)/bin/i386-linux
TEX_ENV?=	PATH=$(TEX_BINDIR):$(PATH) VARTEXMF=$(TEX_DIR)/texmf-var
XALAN?=		$(DOCBOOK_ROOT)/xalan-j_$(XALAN_VERSION)/bin/xalan.sh
XEP?=		sh $(DOCBOOK_ROOT)/XEP/run.sh
XSLTPROC?=	/usr/bin/xsltproc

FO_VERSION?=	FOP
XSLT_TOOL?=	Xalan

# Use one of the following depending on what will be processing the generated
# FO.  The default is to use FOP.  XEP or Passive TeX can be used instead by
# defining $(USE_XEP) or $(USE_PASSIVE_TEX) respectively.
ifeq ($(FO_VERSION), FOP)
   XALAN_FO_PARAMS=	-PARAM fop.extensions "1" # -PARAM column.count "2"
   SAXON_FO_PARAMS=	fop.extensions=1
else
ifeq ($(FO_VERSION), XEP)
   XALAN_FO_PARAMS=	-PARAM xep.extensions "1" # -PARAM column.count "2"
   SAXON_FO_PARAMS=	xep.extensions=1
else
ifeq ($(FO_VERSION), PASSIVE_TEX)
   XALAN_FO_PARAMS=	-PARAM tex.math.in.alt "latex"
   SAXON_FO_PARAMS=	tex.math.in.alt=latex
endif # PASSIVE_TEX
endif # XEP
endif # FOP

XALAN_HTML_PARAMS=	

XALAN_TXT_PARAMS=	-PARAM page.margin.bottom "0in"	\
			-PARAM page.margin.inner "0in"	\
			-PARAM page.margin.outer "0in"	\
			-PARAM page.margin.top "0in"	\
			-PARAM paper.type "A5"

DOCBOOK_ROOT?=	/home/vr/Juggler/docbook
SGML_ROOT?=	/usr/share/sgml/docbook

DB_SGML_DTD?=	$(DOCBOOK_ROOT)/docbook-sgml-4.1.dtd
DSSSL_DIR?=	$(DOCBOOK_ROOT)/docbook-dsssl-1.76
XSL_DIR?=	$(DOCBOOK_ROOT)/docbook-xsl-1.49
#TEXINPUTS=	.:$(DOCBOOK_ROOT)/latex/passivetex:$(DOCBOOK_ROOT)/latex/base:

txt: $(TXT_FILES)

html: images $(HTML_FILES)

chunk-html:
	for file in $(XML_FILES) ; do \
          dir=`echo $$file | sed -e 's/\.xml//'` ; \
          if [ ! -d $$dir ] ; then mkdir $$dir ; fi ; \
          cur_dir=`pwd` ; \
          cd $$dir ; \
          $(SAXON) -i $$cur_dir/$$file -xsl $(XSL_DIR)/html/chunk.xsl $(SAXON_PARAMS); \
          cd $$cur_dir ; \
        done

LINK_DEPS=	images # pdfxmltex.fmt

pdf: $(LINK_DEPS) $(PDF_FILES)

# The method for specifying a path to the images that come with the DocBook
# XSL stylesheets sucks.  It requires a path relative to the current directory,
# and we do not necessarily know how to get to $(XSL_DIR) relative to the
# current directory.  This hack with a symlink works around that problem.
images:
	ln -s $(XSL_DIR)/images ./

ifeq ($(FO_VERSION), PASSIVE_TEX)
pdfxmltex.fmt:
	ln -s $(DOCBOOK_ROOT)/latex/base/pdfxmltex.fmt ./
endif

# Basic XSL conversions -------------------------------------------------------

.xml.html:
ifeq ($(XSLT_TOOL), Xalan)
	$(XALAN) -in $< -xsl $(XSL_DIR)/html/docbook.xsl -out $@	\
          $(XALAN_HTML_PARAMS) $(EXTRA_XALAN_HTML_PARAMS)
else
	$(SAXON) -i $< -xsl $(XSL_DIR)/html/docbook.xsl -o $@		\
          $(SAXON_HTML_PARAMS) $(EXTRA_SAXON_HTML_PARAMS)
endif

.xml.fo:
ifeq ($(XSLT_TOOL), Xalan)
	$(XALAN) -in $< -xsl $(XSL_DIR)/fo/docbook.xsl -out $@		\
          $(XALAN_FO_PARAMS) $(EXTRA_XALAN_FO_PARAMS)
else
	$(SAXON) -i $< -xsl $(XSL_DIR)/fo/docbook.xsl -o $@		\
          $(SAXON_FO_PARAMS) $(EXTRA_SAXON_FO_PARAMS)
endif

.xml.txt:
ifeq ($(XSLT_TOOL), Xalan)
	$(XALAN) -in $< -xsl $(XSL_DIR)/fo/docbook.xsl -out $@		\
          $(XALAN_TXT_PARAMS) $(EXTRA_XALAN_TXT_PARAMS)
else
	$(SAXON) -i $< -xsl $(XSL_DIR)/fo/docbook.xsl -o $@		\
          $(SAXON_TXT_PARAMS) $(EXTRA_SAXON_TXT_PARAMS)
endif
	$(FOP) -fo $< -txt $@

# Generate a PDF file from an FO file using FOP.
ifeq ($(FO_VERSION), FOP)
.fo.pdf:
	$(FOP) $< $@

.fo.txt:
	$(FOP) -fo $< -txt $@
endif

# Generate a PDF file from an XML file using FOP.
#.xml.pdf:
#	$(FOP) -xml $< -xsl $(XSL_DIR)/fo/docbook.xsl -pdf $@

# -----------------------------------------------------------------------------

# Jade/JadeTex conversions ----------------------------------------------------

# Generate a TeX file using Jade.
ifdef USE_JADEPROC
.xml.pdf:
	$(TEX_ENV) $(JADEPROC) -i $< -o $@ -d $(DB_SGML_DTD)		\
          -s $(DSSSL_DIR)/print/docbook.dsl
         
else
.xml.tex:
	$(JADE) -t tex -d $(DSSSL_DIR)/print/docbook.dsl $<

# $(PDFJADETEX) has to be run twice for page references to be calculated.  :(
.tex.pdf:
	-$(TEX_ENV) $(PDFJADETEX) $<
endif

# -----------------------------------------------------------------------------

# PassiveTeX conversions ------------------------------------------------------

# Generate a PDF file from an XML file using PassiveTeX.  This one requires
# that a simple TeX file be generated from the XML first (see below).
ifeq ($(FO_VERSION), PASSIVE_TEX)
.fo.pdf:
	$(TEX_ENV) $(PDFLATEX) "&pdfxmltex" $*.fo
#	$(TEX_ENV) $(PDFLATEX) "&pdfxmltex" $*.fo

# Generate a TeX file for use with PassiveTeX.
#.xml.tex:
#	@echo "Generating $*.tex from $<"
#	@echo '\def\xmlfile{$*.fo}' >$*.tex
#	@echo '\input xmltex' >>$*.tex
endif

# -----------------------------------------------------------------------------

# RenderX XEP conversions -----------------------------------------------------

# Generate a PDF file using XEP from RenderX.  This requires that an FO file
# be generated first.
ifeq ($(FO_VERSION), XEP)
.fo.pdf:
	$(XEP) $*.fo
endif

# -----------------------------------------------------------------------------

clean:
	$(RM) *.aux *.out *.tex *.log *.fo *~

clobber:
	@$(MAKE) clean
	$(RM) *.html *.pdf $(LINK_DEPS)
