# tests/Makefile
#
# Integration and smoke test runner for scripts/sign-objects.sh
#
# Uses:
# - FreeTSA RFC 3161 endpoint: https://freetsa.org/tsr
# - FreeTSA CA certificate:    https://freetsa.org/files/cacert.pem
# - FreeTSA TSA certificate:   https://freetsa.org/files/tsa.crt
#
# This Makefile:
# - prepares local fixture artefacts
# - downloads the current FreeTSA verification certificates
# - checks that the sign script exists
# - runs all test scripts with colored PASS/FAIL output
#
# Notes:
# - Tests are primarily integration/smoke tests
# - Authoritative DNS publication is NOT performed
# - The sign script is treated as a technical demonstration tool
# scripts/tests/Makefile

SHELL := /usr/bin/env bash

# Current directory = scripts/tests
TEST_DIR := $(CURDIR)

# Script under test (one level up)
TEST_SCRIPT := $(abspath $(TEST_DIR)/../sign-objects.sh)
export TEST_SIGN_SCRIPT := $(abspath $(TEST_DIR)/../sign-objects.sh)
export TEST_CONSUMER_SCRIPT := $(abspath $(TEST_DIR)/../consumer-validation.sh)

TEST_DIR := $(CURDIR)
TEST_SCRIPT := $(abspath $(TEST_DIR)/../sign-objects.sh)
TEST_CONSUMER_SCRIPT := $(abspath $(TEST_DIR)/../consumer-validation.sh)

FIXTURE_DIR := $(TEST_DIR)/fixtures
CERT_DIR := $(TEST_DIR)/certs
WORK_DIR := $(TEST_DIR)/.work

FREetsa_TSR_URL := https://freetsa.org/tsr
FREetsa_CA_URL  := https://freetsa.org/files/cacert.pem
FREetsa_TSA_URL := https://freetsa.org/files/tsa.crt

export TSA_URL := $(FREetsa_TSR_URL)
export TSA_CA_FILE := $(CERT_DIR)/cacert.pem
export TSA_UNTRUSTED_FILE := $(CERT_DIR)/tsa.crt
export TEST_TRUST_DOMAIN := teatrust.example.test
export TEST_PERSISTENCE_DOMAIN := teatrust.archive.example.test
export TEST_SCRIPT := $(TEST_SCRIPT)

TESTS := \
	$(TEST_DIR)/01-sign-raw-success.sh \
	$(TEST_DIR)/02-sign-jcs-success.sh \
	$(TEST_DIR)/03-missing-tsa-url-fails.sh \
	$(TEST_DIR)/04-destroy-keys.sh \
	$(TEST_DIR)/05-persistence-san.sh \
	$(TEST_DIR)/06-invalid-json-jcs-fails.sh \
	$(TEST_DIR)/07-evidence-manifest-check.sh \
	$(TEST_DIR)/11-consumer-raw-success.sh \
	$(TEST_DIR)/12-consumer-jcs-success.sh \
	$(TEST_DIR)/13-consumer-tampered-artefact-fails.sh \
	$(TEST_DIR)/14-consumer-metadata-mismatch-fails.sh \
	$(TEST_DIR)/15-consumer-missing-timestamp-fails.sh \
	$(TEST_DIR)/16-consumer-evidence-manifest-mismatch-fails.sh \
	$(TEST_DIR)/17-consumer-verify-time-outside-cert-fails.sh \
	$(TEST_DIR)/18-consumer-tampered-metadata-fails.sh \
	$(TEST_DIR)/19-signing-tsa-unreachable-fails.sh

.PHONY: all test clean prepare-fixtures prepare-certs check-script

all: test

check-script:
	@test -f "$(TEST_SCRIPT)" || { \
		echo "ERROR: sign script not found: $(TEST_SCRIPT)" >&2; \
		exit 1; \
	}
	@test -x "$(TEST_SCRIPT)" || { \
		echo "ERROR: sign script is not executable: $(TEST_SCRIPT)" >&2; \
		exit 1; \
	}

test: check-script prepare-fixtures prepare-certs
	@mkdir -p "$(WORK_DIR)"
	@set -e; \
	GREEN="\033[32m"; \
	RED="\033[31m"; \
	RESET="\033[0m"; \
	for t in $(TESTS); do \
		printf "==> Running %s\n" "$$t"; \
		if bash "$$t"; then \
			printf "$${GREEN}✅ PASS$${RESET} %s\n" "$$t"; \
		else \
			printf "$${RED}❌ FAIL$${RESET} %s\n" "$$t"; \
			exit 1; \
		fi; \
	done
	@echo
	@printf "\033[32mAll tests passed.\033[0m\n"

prepare-fixtures: \
	$(FIXTURE_DIR)/sample.bin \
	$(FIXTURE_DIR)/sample.json \
	$(FIXTURE_DIR)/invalid.json

prepare-certs: \
	$(CERT_DIR)/cacert.pem \
	$(CERT_DIR)/tsa.crt

$(FIXTURE_DIR):
	mkdir -p "$@"

$(CERT_DIR):
	mkdir -p "$@"

$(WORK_DIR):
	mkdir -p "$@"

$(FIXTURE_DIR)/sample.bin: | $(FIXTURE_DIR)
	printf 'hello tea trust architecture\n' > "$@"

$(FIXTURE_DIR)/sample.json: | $(FIXTURE_DIR)
	printf '%s\n' '{' \
	  '  "b": 2,' \
	  '  "a": 1,' \
	  '  "publisher": {' \
	  '    "name": "Example Publisher"' \
	  '  }' \
	  '}' > "$@"

$(FIXTURE_DIR)/invalid.json: | $(FIXTURE_DIR)
	printf '%s\n' '{ "a": 1,, }' > "$@"

$(CERT_DIR)/cacert.pem: | $(CERT_DIR)
	curl -sS --fail --location "$(FREetsa_CA_URL)" -o "$@"

$(CERT_DIR)/tsa.crt: | $(CERT_DIR)
	curl -sS --fail --location "$(FREetsa_TSA_URL)" -o "$@"

clean:
	rm -rf "$(WORK_DIR)" "$(FIXTURE_DIR)" "$(CERT_DIR)"
