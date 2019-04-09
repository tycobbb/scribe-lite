include ../Makefile.base.mk

# -- cosmetics --
help-column-width = 10

# -- start/stop --
## starts the api server
start:
	cargo run
.PHONY: start

## builds the api code
build:
	cargo build
.PHONY: build

# -- verify --
## verifies the api code
verify: v/format
.PHONY: verify

## checks the code format
v/format:
	$(format) --check
.PHONY: v/format

## fixes any formatting errors
v/f/fix:
	$(format)
.PHONY: v/f/fix

format = rustfmt ./**/*.rs

# -- db --
## resets the database
db/reset:
	diesel database reset
.PHONY: db/reset

## runs the database migrations
db/migrate:
	diesel migration run
.PHONY: db/migrate

## creates a new database migration
db/m/new:
	diesel migration generate PLACEHOLDERS
.PHONY: db/m/new

## re-runs the most recent migration
db/m/redo:
	diesel migration redo
.PHONY: db/m/redo

## rolls back the most recent migration
db/m/undo:
	diesel migration revert
.PHONY: db/m/undo
