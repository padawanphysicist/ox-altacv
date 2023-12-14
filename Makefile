# Name of your emacs binary
EMACS=emacs

BATCH=$(EMACS) --debug --batch --no-init-file	\
	--load src/ox-altacv.el						\
	--load example/publish.el

.PHONY: example
example: example/mmayer.org
	@$(BATCH) --funcall org-publish-example

.PHONY: clean
clean:
	rm -rf *.aux *.bcf *.log *.out *.xml *.xmpi *.bbl
	cd example/ && rm -rf *.aux *.bcf *.log *.out *.xml *.xmpi *.tex *.pdf *.bbl
