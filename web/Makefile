include ../Makefile.base.mk

# -- cosmetics --
help-column-width = 10

# -- context --
# location for js binaries
jbin = ./node_modules/.bin

# -- start/stop --
## starts the dev server
start:
	$(jbin)/ts-node index.ts
.PHONY: start

## kills the running dev server
s/kill:
	lsof -t -i:3000 | xargs kill
.PHONY: s/kill
