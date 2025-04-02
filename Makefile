.PHONY: init refresh audit clean

init:
	git submodule add https://github.com/anthropics/claude-code claude-code-repo
	git submodule update --init --recursive

refresh:
	git submodule update --remote

audit:
	./npm-package-audit.sh

clean:
	rm -rf versions

all: init audit
