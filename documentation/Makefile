SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = source
BUILDDIR      = build

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" -W $(SPHINXOPTS) $(O)

dist: Makefile
	@ruby footer.rb
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" -W $(SPHINXOPTS) $(O)

	@for tool in dox_style dox_util dox_trace dim ; do \
		ruby ../$$tool/documentation/footer.rb ; \
		$(MAKE) -C ../$$tool/documentation html ; \
		mkdir -p build/html/$$tool ; \
		cp -rf ../$$tool/documentation/build/html/* build/html/$$tool ; \
	done
