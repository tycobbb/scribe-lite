include ../Makefile.base.mk

# -- cosmetics --
help-column-width = 15

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
v/format/fix:
	$(format)
.PHONY: v/format/fix

format = rustfmt ./**/*.rs

# -- db --
## alias for db/log
db: db/log
.PHONY: db

## tails the postgres log
db/log:
	tail -f /usr/local/var/log/postgres.log
.PHONY: db/log

## resets the database
db/reset:
	diesel database reset
.PHONY: db/reset

## runs the database migrations
db/migrate:
	diesel migration run
.PHONY: db/migrate

## creates a new database migration
db/migrate/new:
	diesel migration generate PLACEHOLDERS
.PHONY: db/migrate/new

## rollback the most recent migration
db/migrate/undo:
	diesel migration revert
.PHONY: db/migrate/undo

## rollback and re-apply the most recent migration
db/migrate/redo:
	diesel migration redo
.PHONY: db/migrate/redo
