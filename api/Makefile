.DEFAULT_GOAL := help

# -- run/stop --
## starts the api server
s:
	cargo run

.PHONY: s

# -- build --
## builds the api code
b:
	cargo build

.PHONY: b

# -- help --
help:
	@awk "$$HELP" $(MAKEFILE_LIST)

define HELP
BEGIN {
	print "\033[4;37musage:\033[0m";
	print "  \033[1;37mmake <command>\033[0m\n";
	print "\033[4;37mcommands:\033[0m";
}
/^## (.*)$$/ {
	$$1=""; docs=$$0;
	getline;
	sub(/:/, "", $$1);
	printf "  \033[1;31m%-2s\033[0;90m %s\033[0m\n", $$1, docs;
}
endef
export HELP

.PHONY = help
