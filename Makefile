# Sane defaults
SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Default params
SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# ---------------------- Includes ---------------------------
include $(wildcard $(SELF_DIR)/build/*.mk)

# ---------------------- VARIABLES ---------------------------

# ---------------------- COMMANDS ---------------------------

.PHONY: init
init: # Initialize the repository
	@echo Not Implemented

.PHONY: build
build: # Builds the application
	@echo Not Implemented

.PHONY: test
test: # Runs all automated tests
	@echo Not Implemented

.PHONY: run
run: # Executes the built application in the local environment
	@echo Not Implemented

.PHONY: generate
generate: # Runs code generation tasks
	@echo Not Implemented

.PHONY: fmt
fmt: # Formats source code
	@echo Not Implemented

.PHONY: verify
verify: # Checks code quality (linting, formatting, static analysis)
	@echo Not Implemented

.PHONY: package
package: # Builds and packages the application for distribution
	@echo Not Implemented

.PHONY: testresults
testresults: # Aggregates and reports test results
	@echo Not Implemented
