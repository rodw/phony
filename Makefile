# ## coffee and node

# the coffee executable
COFFEE_EXE ?= coffee
# the node executable
NODE_EXE ?= node
# command to compile .coffee files
COFFEE_COMPILE ?= $(COFFEE_EXE) -c
# additional arguments when compiling .coffee files
COFFEE_COMPILE_ARGS ?= -l
# list of .coffee files
COFFEE_SRCS ?= $(wildcard lib/*.coffee)
COFFEE_TEST_SRCS ?= $(wildcard test/*.coffee)
# list of .js files generated from .coffee files
COFFEE_JS ?= ${COFFEE_SRCS:.coffee=.js}

# ## npm

# the npm executable
NPM_EXE ?= npm
# the npm package file
PACKAGE_JSON ?= package.json
# where npm installs external modules
NODE_MODULES ?= node_modules
# where to place the generated module
MODULE_DIR ?= module

# ## node-jscoverage

# the jscoverage executable
JSCOVERAGE_EXE ?= node-jscoverage
# the generated jscoverage report
JSCOVERAGE_REPORT ?= docs/coverage.html
# temporary container for js files to be instrumented
JSCOVERAGE_TMP_DIR ?=  ./jscov-tmp
# container for instrumented js files
LIB_COV ?= lib-cov
# container for uninstrumented coffee/js files
LIB ?= lib
# args to pass to mocha during coverage runs
MOCHA_COV_ARGS  ?= -R html-cov --compilers coffee:coffee-script --globals "_\$$jscoverage"

# ## markdown

# list of markdown documention ifiles
MARKDOWN_SRCS ?= $(wildcard *.md) $(wildcard docs/*.md)
# list of html files generated from markdown
MARKDOWN_HTML ?= ${MARKDOWN_SRCS:.md=.html}
# executable to process markdown
MARKDOWN_PROCESSOR ?= pandoc
# arguments to pass to markdown executable
MARKDOWN_PROCESSOR_ARGS ?= -f markdown -t html -s

# ## mocha and unit testing

# mocha executabable
MOCHA_EXE ?= mocha
# list of mocha test files
MOCHA_TESTS ?= $(wildcard test/*.coffee)
# args to pass to mocha during test runs
MOCHA_TEST_ARGS  ?= -R list --compilers coffee:coffee-script

# ## miscellaneous

# additional flag passed to `rm`. set to `-i` to force confirmation before removing files.
RM_DASH_I ?= -f

# reset suffixes in case any were previously defined
.SUFFIXES:

# # TARGETS

# ## "Meta" Targets

# `.PHONY` - make targets that aren't actually files
.PHONY: all build-coffee clean clean-coverage clean-docco clean-docs clean-test-module-install clean-js clean-markdown clean-module clean-node-modules coffee.js coverage docco docs fully-clean-node-modules help js markdown module targets test test-module-install todo

# `clean` - delete all generated files
clean: clean-coverage clean-docco clean-docs clean-js clean-module clean-node-modules

# `all` - the default target
all: coverage docco

# `help` - list targets.
help:
	make -rpn | sed -n -e '/^$$/ { n ; /^[^ ]*:/p }' | egrep -v '^\.' | egrep --color '^[^ ]*:'

# `targets` - list Makefile targets that are likely to be .PHONY targets
targets:
	grep -E "^[^ #.$$]+:( |$$)" Makefile | sort

# ## NPM targets

# `module` - create an npm-publishable module directory
module: js test docs coverage
	mkdir -p $(MODULE_DIR)
	cp -r lib $(MODULE_DIR)
	cp -r test $(MODULE_DIR)
	cp -r bin $(MODULE_DIR)
	cp -r docs $(MODULE_DIR)
	cp $(PACKAGE_JSON) $(MODULE_DIR)
	cp README.* $(MODULE_DIR)
	cp Makefile $(MODULE_DIR)

test-module-install: clean-test-module-install module
	mkdir ../testing-module-install; cd ../testing-module-install; npm install ../phony/module; node -e "require('assert').ok(require('phony').make_phony().name())"; cd ../phony; rm -r $(RM_DASH_I) ../testing-module-install

clean-test-module-install:
	rm -r $(RM_DASH_I) ../testing-module-install

# `clean-module` - remove the `$(MODULE_DIR)`
clean-module:
	rm -r $(RM_DASH_I) $(MODULE_DIR)

# `$(NODE_MODULES)` - install node dependencies via npm
$(NODE_MODULES): $(PACKAGE_JSON)
	$(NPM_EXE) prune
	$(NPM_EXE) install
	touch $(NODE_MODULES) # touch the module dir so it looks younger than `package.json`

# `clean-node-modules` - prune modules in `node_modules` that are no longer used
clean-node-modules:
	$(NPM_EXE) prune

# `fully-clean-node-modules` - delete the `node_modules` directory outright.
fully-clean-node-modules:
	rm -r $(RM_DASH_I) $(NODE_MODULES)

# ## Coffee/JS Targets

# `build-coffee` - build everything we need to run under coffee
build-coffee: $(NODE_MODULES)
	rm -r $(RM_DASH_I) $(LIB_COV)

# `js` - build everything we need to run under js/node
js: build-coffee $(COFFEE_JS)

# `.coffee.js` - compile coffee files into js files
.SUFFIXES: .js .coffee
.coffee.js:
	$(COFFEE_COMPILE) $(COFFEE_COMPILE_ARGS) $<
$(COFFEE_JS_OBJ): $(NODE_MODULES) $(COFFEE_SRCS)

# `clean-js` - remove generated js files
clean-js:
	rm $(RM_DASH_I) $(COFFEE_JS)

# ## Unit Testing Tasks

# `test` - run the unit test suite
test: js $(MOCHA_TESTS)
	$(MOCHA_EXE) $(MOCHA_TEST_ARGS) $(MOCHA_TESTS)

# `coverage` - instrument code, run test suite, report test coverage
coverage: js
	rm -r $(RM_DASH_I) $(JSCOVERAGE_TMP_DIR)
	rm -r $(RM_DASH_I) $(LIB_COV)
	mkdir -p $(JSCOVERAGE_TMP_DIR)
	cp $(LIB)/*.js $(JSCOVERAGE_TMP_DIR)/.
	$(JSCOVERAGE_EXE) -v $(JSCOVERAGE_TMP_DIR) $(LIB_COV)
	mkdir -p `dirname $(JSCOVERAGE_REPORT)`
	$(MOCHA_EXE) $(MOCHA_COV_ARGS) $(MOCHA_TESTS) > $(JSCOVERAGE_REPORT)
	rm -r $(RM_DASH_I) $(JSCOVERAGE_TMP_DIR)
	rm -r $(RM_DASH_I) $(LIB_COV)

# `clean-coverage` - remove files generated by `coverage`
clean-coverage:
	rm -r $(RM_DASH_I) $(JSCOVERAGE_TMP_DIR)
	rm -r $(RM_DASH_I) $(LIB_COV)
	rm $(RM_DASH_I) $(JSCOVERAGE_REPORT)

# ## Documentation Related Tasks

# `docs` - generate documentation
docs: markdown docco

# `clean-docs` - remove files generated by `docs`
clean-docs: clean-markdown clean-docco

# ### Markdown

# `.md.html` - compile markdown documention into html
.SUFFIXES: .html .md
.md.html:
	$(MARKDOWN_PROCESSOR) $(MARKDOWN_PROCESSOR_ARGS) -o $@ $<
$(MARKDOWN_HTML_OBJ): $(MARKDOWN_SRCS)

# `clean-markdown-html` - remove generated html files
clean-markdown:
	rm $(RM_DASH_I) $(MARKDOWN_HTML)

# `markdown` - compile all markdown documentation into html
markdown: $(MARKDOWN_HTML)

# ### Docco

# `docco` - generate docco documentation from coffee sources
docco: $(COFFEE_SRCS) $(COFFEE_TEST_SRCS) $(NODE_MODULES)
	rm -r $(RM_DASH_I) docs/docco
	mkdir -p docs
	mv docs docs-temporarily-renamed-so-docco-doesnt-clobber-it
	docco $(COFFEE_SRCS) $(COFFEE_TEST_SRCS)
	mv docs docs-temporarily-renamed-so-docco-doesnt-clobber-it/docco
	mv docs-temporarily-renamed-so-docco-doesnt-clobber-it docs

# `clean-docco` - remove docco generated html files
clean-docco:
	rm -r $(RM_DASH_I) docs/docco

# `todo` - list todo comments
todo:
	grep -C 0 --exclude-dir=node_modules --exclude-dir=.git --exclude=#*# --exclude=.#* -IrH "TODO" *

