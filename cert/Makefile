.PHONY: deps install root-ca cert clean verify help

ARCH := $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')
OS   := $(shell uname | tr '[:upper:]' '[:lower:]')
EASYRSA_VERSION := 3.1.7
PKI_DIR := ./pki
TLS_DIR := ./tls
TLS_NAME := server

# Certificate domains (can be overridden with environment variable)
COMMON_NAME ?= aws-vpn-dev
ALT_NAMES ?= DNS:$(COMMON_NAME),DNS:ovpn.cnapcloud.com

deps: ## Install required system dependencies
ifeq ($(OS),linux)
	sudo apt-get update -qq
	sudo apt-get install -y openssl
else ifeq ($(OS),darwin)
	brew install openssl || true
endif

install: deps ## Download and install EasyRSA
	@echo "Downloading EasyRSA $(EASYRSA_VERSION)..."
	@curl -sSL https://github.com/OpenVPN/easy-rsa/releases/download/v$(EASYRSA_VERSION)/EasyRSA-$(EASYRSA_VERSION).tgz -o easyrsa.tgz
	@tar xzf easyrsa.tgz
	@chmod +x EasyRSA-$(EASYRSA_VERSION)/easyrsa
	@sudo cp EasyRSA-$(EASYRSA_VERSION)/easyrsa /usr/local/bin/easyrsa
	@rm -rf easyrsa.tgz EasyRSA-$(EASYRSA_VERSION)
	@echo "EasyRSA installed to /usr/local/bin/easyrsa"

root-ca: ## Create root CA if not exists
	@if [ ! -f $(PKI_DIR)/ca.crt ]; then \
		echo "Initializing PKI..."; \
		easyrsa init-pki; \
		echo "Building CA..."; \
		EASYRSA_BATCH=1 easyrsa build-ca nopass; \
		echo "Root CA generated at $(PKI_DIR)/ca.crt"; \
	else \
		echo "Root CA already exists at $(PKI_DIR)/ca.crt"; \
	fi

cert: root-ca ## Generate server certificates with Common Name
	@echo "Generating server certificate with CN=$(COMMON_NAME)..."
	@mkdir -p $(TLS_DIR)
	@if [ -f $(PKI_DIR)/issued/$(COMMON_NAME).crt ]; then \
		echo "Certificate already exists,deleting and regenerating..."; \
		rm -f $(PKI_DIR)/issued/$(COMMON_NAME).crt; \
		rm -f $(PKI_DIR)/private/$(COMMON_NAME).key; \
		rm -f $(PKI_DIR)/reqs/$(COMMON_NAME).req; \
	fi
	@EASYRSA_BATCH=1 EASYRSA_CERT_EXPIRE=3650 easyrsa --subject-alt-name="$(ALT_NAMES)" \
		build-server-full $(COMMON_NAME) nopass
	@cp $(PKI_DIR)/issued/$(COMMON_NAME).crt $(TLS_DIR)/$(TLS_NAME).crt
	@cp $(PKI_DIR)/private/$(COMMON_NAME).key $(TLS_DIR)/$(TLS_NAME).key
	@cp $(PKI_DIR)/ca.crt $(TLS_DIR)/ca.crt
	@echo ""
	@echo "Certificates generated in $(TLS_DIR)/"

clean: ## Remove generated certificates and EasyRSA files
	@echo "Cleaning up..."
	@rm -rf $(PKI_DIR) $(TLS_DIR)
	@echo "Cleanup complete"

verify: ## Verify generated certificate
	@echo "Certificate information:"
	@openssl x509 -in $(TLS_DIR)/$(TLS_NAME).crt -noout -subject
	@echo ""
	@echo "Subject Alternative Names:"
	@openssl x509 -in $(TLS_DIR)/$(TLS_NAME).crt -noout -text | grep -A1 "Subject Alternative Name"
	@echo ""
	@echo "Validity:"
	@openssl x509 -in $(TLS_DIR)/$(TLS_NAME).crt -noout -dates

help: ## Show available targets
	@echo "Usage: make <target>"
	@echo ""
	@echo "Environment Variables:"
	@echo "  COMMON_NAME    Certificate Common Name (default: vpn.cnapcloud.com)"
	@echo "  ALT_NAMES      Subject Alternative Names (default: DNS:vpn.cnapcloud.com)"
	@echo ""
	@echo "Examples:"
	@echo "  make cert COMMON_NAME=vpn.example.com"
	@echo "  make cert COMMON_NAME=vpn.example.com ALT_NAMES='DNS:vpn.example.com,DNS:*.example.com'"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk -F ':.*?## ' '{printf "  %-15s %s\n", $$1, $$2}'