.PHONY: deps install root-ca cert help

ARCH := $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
OS   := $(shell uname | tr '[:upper:]' '[:lower:]')

VERSION := v1.4.3
CAROOT  := ./root-ca
TLS_DIR := ./tls
TLS_NAME := server

# Certificate domains (can be overridden with environment variable)
DOMAINS ?= vpn.cnapcloud.com

deps: ## Install required system dependencies
ifeq ($(OS),linux)
	sudo apt-get update -qq
	sudo apt-get install -y libnss3-tools
else ifeq ($(OS),darwin)
	brew install mkcert nss || true
endif

install: deps ## Install mkcert
ifeq ($(OS),linux)
	curl -sSL -o mkcert \
	  https://github.com/FiloSottile/mkcert/releases/download/$(VERSION)/mkcert-$(VERSION)-linux-$(ARCH)
	chmod +x mkcert
	sudo mv mkcert /usr/local/bin/mkcert
else ifeq ($(OS),darwin)
	@echo "mkcert installed via brew"
endif

cert: ## Create root CA if not exists and generate server certificates
	mkdir -p $(TLS_DIR)
	CAROOT=$(CAROOT) mkcert \
	  -cert-file $(TLS_DIR)/$(TLS_NAME).crt \
	  -key-file  $(TLS_DIR)/$(TLS_NAME).key \
	  $(DOMAINS)

help: ## Show available targets
	@echo "Usage: make <target>"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk -F ':.*?## ' '{printf "  %-15s %s\n", $$1, $$2}'
