comma := ,

.PHONY: help
help = help::; @echo $$$$(tput bold)$(strip $(1)):$$$$(tput sgr0) $(strip $(2))
$(call help,make help,print this help message)

.PHONY: services

.PHONY: devdata
$(call help,make devdata,load development data and environment variables)
devdata: python
	@tox -qe dev --run-command 'python bin/make_devdata'

.PHONY: dev
$(call help,make dev,run the whole app \(all workers\))
dev: python
	@pyenv exec tox -qe dev

# Tell make how to compile requirements/*.txt files.
#
# `touch` is used to pre-create an empty requirements/%.txt file if none
# exists, otherwise tox crashes.
#
# $(subst) is used because in the special case of making prod.txt we actually
# need to touch dev.txt not prod.txt and we need to run `tox -e dev ...`
# not `tox -e prod ...`
#
# $(basename $(notdir $@))) gets just the environment name from the
# requirements/%.txt filename, for example requirements/foo.txt -> foo.
requirements/%.txt: requirements/%.in python
	@touch -a $(subst prod.txt,dev.txt,$@)
	@tox -qe $(subst prod,dev,$(basename $(notdir $@))) --run-command 'pip --quiet --disable-pip-version-check install pip-tools pip-sync-faster'
	@tox -qe $(subst prod,dev,$(basename $(notdir $@))) --run-command 'pip-compile --allow-unsafe --quiet $(args) $<'

# Inform make of the dependencies between our requirements files so that it
# knows what order to re-compile them in and knows to re-compile a file if a
# file that it depends on has been changed.
requirements/dev.txt: requirements/prod.txt

# Add a requirements target so you can just run `make requirements` to
# re-compile *all* the requirements files at once.
#
# This needs to be able to re-create requirements/*.txt files that don't exist
# yet or that have been deleted so it can't just depend on all the
# requirements/*.txt files that exist on disk $(wildcard requirements/*.txt).
#
# Instead we generate the list of requirements/*.txt files by getting all the
# requirements/*.in files from disk ($(wildcard requirements/*.in)) and replace
# the .in's with .txt's.
.PHONY: requirements requirements/
$(call help,make requirements,"compile the requirements files")
requirements requirements/: $(foreach file,$(wildcard requirements/*.in),$(basename $(file)).txt)

.PHONY: template
$(call help,make template,"update from the latest cookiecutter template")
template: python
	@pyenv exec tox -e template -- $$(if [ -n "$${template+x}" ]; then echo "--template $$template"; fi) $$(if [ -n "$${checkout+x}" ]; then echo "--checkout $$checkout"; fi) $$(if [ -n "$${directory+x}" ]; then echo "--directory $$directory"; fi)

.PHONY: docker
$(call help,make docker,"make the app's docker image")
docker:
	@git archive --format=tar HEAD | docker build -t hypothesis/flower:dev -

.PHONY: docker-run
$(call help,make docker-run,"run the app's docker image")
docker-run:
	@bin/make_docker_run

.PHONY: clean
$(call help,make clean,"delete temporary files etc")
clean:
	@rm -rf build dist .tox .coverage coverage .eslintcache node_modules supervisord.log supervisord.pid yarn-error.log
	@find . -path '*/__pycache__*' -delete
	@find . -path '*.egg-info*' -delete

.PHONY: python
python:
	@bin/make_python
