.DEFAULT_GOAL := help

# -- context --
# location for js binaries
jbin = ./node_modules/.bin

# -- run/stop --
## starts the dev server
s:
	$(jbin)/ts-node index.ts
.PHONY: s

## kills the running dev server
s/kill:
	lsof -t -i:3000 | xargs kill
.PHONY: s/kill

# -- help --
help:
	@awk "$$HELP" $(MAKEFILE_LIST)

define HELP
BEGIN {
	print "\033[4;37musage:\033[0m";
	print "  \033[1;37mmake <target>\033[0m\n";
	print "\033[4;37mcommands:\033[0m";
}
/^## (.*)$$/ {
	$$1=""; docs=$$0;
	getline;
	sub(/:/, "", $$1);
	printf "  \033[1;31m%-7s\033[0;90m %s\033[0m\n", $$1, docs;
}
endef
export HELP

.PHONY: help
