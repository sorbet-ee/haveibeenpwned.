# ============================================================================
# HaveIBeenPwned Ruby Gem - Makefile
# ============================================================================
# This Makefile provides convenient commands for common development tasks.
# It follows GNU Make conventions and includes extensive documentation.
#
# Usage:
#   make              # Run default target (test)
#   make help         # Show all available targets with descriptions
#   make test         # Run the test suite
#   make build        # Build the gem package
#   make install      # Install gem locally
#   make demo         # Run interactive demo
#
# Variables can be overridden:
#   make test TESTOPTS="--verbose"
#   make build VERSION=0.2.0
# ============================================================================

# ----------------------------------------------------------------------------
# Configuration Variables
# ----------------------------------------------------------------------------

# Gem name (used for building and cleaning)
GEM_NAME := sorbet-hibp

# Current version (extracted from version.rb)
VERSION := $(shell ruby -r ./lib/haveibeenpwned/version.rb -e 'puts HaveIBeenPwned::VERSION')

# Gem file name
GEM_FILE := $(GEM_NAME)-$(VERSION).gem

# Ruby command (can be overridden for different Ruby versions)
RUBY := ruby

# Bundler command
BUNDLE := bundle

# Rake command (via bundler)
RAKE := $(BUNDLE) exec rake

# Test options (can be extended via command line)
TESTOPTS :=

# Build directory for gem packages
BUILD_DIR := pkg

# Documentation output directory
DOCS_DIR := doc

# Color output for better readability
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# ----------------------------------------------------------------------------
# Phony Targets
# ----------------------------------------------------------------------------
# Declare targets that don't represent actual files to avoid conflicts
# with files of the same name and to improve performance

.PHONY: help default all install clean test test-unit test-integration \
        test-verbose test-coverage build release demo demo-passwords \
        demo-breaches demo-errors console format lint docs deps check \
        version info

# ----------------------------------------------------------------------------
# Default Target
# ----------------------------------------------------------------------------
# The default target runs when you type 'make' without arguments
# We default to running tests as it's the most common development task

default: test

# ----------------------------------------------------------------------------
# Help Target
# ----------------------------------------------------------------------------
# Displays all available targets with descriptions
# This makes the Makefile self-documenting

help:
	@echo "$(CYAN)HaveIBeenPwned Gem - Available Make Targets$(NC)"
	@echo ""
	@echo "$(GREEN)Setup & Dependencies:$(NC)"
	@echo "  deps           - Install all dependencies via bundler"
	@echo "  check          - Verify environment is properly configured"
	@echo ""
	@echo "$(GREEN)Testing:$(NC)"
	@echo "  test           - Run the complete test suite"
	@echo "  test-unit      - Run only unit tests"
	@echo "  test-verbose   - Run tests with verbose output"
	@echo "  test-coverage  - Run tests with coverage report"
	@echo ""
	@echo "$(GREEN)Building & Installation:$(NC)"
	@echo "  build          - Build gem package (.gem file)"
	@echo "  install        - Build and install gem locally"
	@echo "  clean          - Remove built gem files and artifacts"
	@echo ""
	@echo "$(GREEN)Development:$(NC)"
	@echo "  demo           - Run interactive demo of all features"
	@echo "  demo-passwords - Demo Pwned Passwords API only"
	@echo "  demo-breaches  - Demo breach lookups with test accounts"
	@echo "  demo-errors    - Demo error handling"
	@echo "  console        - Start IRB console with gem loaded"
	@echo ""
	@echo "$(GREEN)Code Quality:$(NC)"
	@echo "  lint           - Run RuboCop linter (if available)"
	@echo "  format         - Auto-format code with RuboCop"
	@echo "  docs           - Generate YARD documentation"
	@echo ""
	@echo "$(GREEN)Information:$(NC)"
	@echo "  version        - Display current gem version"
	@echo "  info           - Display gem and environment information"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make test TESTOPTS='--verbose'  # Run tests verbosely"
	@echo "  make install                     # Install gem locally"
	@echo "  make demo                        # Try out the gem"

# ----------------------------------------------------------------------------
# Setup & Dependencies
# ----------------------------------------------------------------------------

# Install all gem dependencies
# This runs 'bundle install' which reads Gemfile and installs required gems
deps:
	@echo "$(CYAN)Installing dependencies...$(NC)"
	@$(BUNDLE) install
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

# Verify the development environment is properly configured
# Checks for required tools and provides helpful error messages
check:
	@echo "$(CYAN)Checking environment...$(NC)"
	@command -v ruby >/dev/null 2>&1 || { echo "$(RED)✗ Ruby is not installed$(NC)"; exit 1; }
	@command -v bundle >/dev/null 2>&1 || { echo "$(RED)✗ Bundler is not installed. Run: gem install bundler$(NC)"; exit 1; }
	@test -f Gemfile.lock || { echo "$(YELLOW)! Gemfile.lock not found. Run: make deps$(NC)"; exit 1; }
	@echo "$(GREEN)✓ Ruby version: $$(ruby -v)$(NC)"
	@echo "$(GREEN)✓ Bundler version: $$(bundle -v)$(NC)"
	@echo "$(GREEN)✓ Environment check passed$(NC)"

# ----------------------------------------------------------------------------
# Testing Targets
# ----------------------------------------------------------------------------
# These targets run the test suite in various configurations

# Run the complete test suite
# This is the primary testing target used in CI/CD and daily development
test: deps
	@echo "$(CYAN)Running test suite...$(NC)"
	@$(RAKE) test $(TESTOPTS)
	@echo "$(GREEN)✓ All tests passed$(NC)"

# Run only unit tests (fast tests without network calls)
# Useful during development for quick feedback
test-unit: deps
	@echo "$(CYAN)Running unit tests...$(NC)"
	@$(RUBY) -Ilib:test test/errors_test.rb
	@echo "$(GREEN)✓ Unit tests passed$(NC)"

# Run tests with verbose output
# Shows each test name as it runs, useful for debugging
test-verbose: deps
	@echo "$(CYAN)Running tests with verbose output...$(NC)"
	@$(RAKE) test TESTOPTS="--verbose"

# Run tests with coverage report
# Requires simplecov gem (optional dependency)
test-coverage: deps
	@echo "$(CYAN)Running tests with coverage...$(NC)"
	@COVERAGE=true $(RAKE) test
	@echo "$(GREEN)✓ Coverage report generated in coverage/$(NC)"

# ----------------------------------------------------------------------------
# Building & Installation
# ----------------------------------------------------------------------------

# Build the gem package
# Creates a .gem file in the pkg/ directory that can be distributed
build: clean deps test
	@echo "$(CYAN)Building gem package...$(NC)"
	@mkdir -p $(BUILD_DIR)
	@gem build $(GEM_NAME).gemspec
	@mv $(GEM_FILE) $(BUILD_DIR)/
	@echo "$(GREEN)✓ Built $(BUILD_DIR)/$(GEM_FILE)$(NC)"

# Install the gem locally
# Builds and installs the gem on your system for testing
install: build
	@echo "$(CYAN)Installing gem locally...$(NC)"
	@gem install $(BUILD_DIR)/$(GEM_FILE)
	@echo "$(GREEN)✓ Gem installed. Try: irb -r haveibeenpwned$(NC)"

# Uninstall the gem
# Removes the locally installed gem
uninstall:
	@echo "$(CYAN)Uninstalling gem...$(NC)"
	@gem uninstall $(GEM_NAME) -x || true
	@echo "$(GREEN)✓ Gem uninstalled$(NC)"

# Clean build artifacts
# Removes generated files to start fresh
clean:
	@echo "$(CYAN)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR)
	@rm -f $(GEM_NAME)-*.gem
	@rm -rf $(DOCS_DIR)
	@rm -rf coverage
	@rm -rf .bundle
	@rm -f Gemfile.lock
	@echo "$(GREEN)✓ Cleaned$(NC)"

# ----------------------------------------------------------------------------
# Demo & Examples
# ----------------------------------------------------------------------------
# Interactive demonstrations of the gem's functionality

# Run comprehensive interactive demo
# Shows all major features of the gem with real API calls
demo: deps
	@echo "$(CYAN)======================================$(NC)"
	@echo "$(CYAN)  HaveIBeenPwned Gem - Live Demo$(NC)"
	@echo "$(CYAN)======================================$(NC)"
	@echo ""
	@$(RUBY) -Ilib -r haveibeenpwned -e ' \
		puts "#{"\033[0;33m"}1. Pwned Passwords (No API Key Needed)#{"\033[0m"}"; \
		puts "Checking if \"password\" has been pwned..."; \
		count = HaveIBeenPwned::PwnedPasswords.check("password"); \
		puts "  → Found #{count.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1,").reverse} times! 💀\n\n"; \
		\
		puts "#{"\033[0;33m"}2. Checking a Strong Password#{"\033[0m"}"; \
		puts "Checking \"MyV3ry$tr0ngP@ssw0rd!2024XYZ\"..."; \
		count = HaveIBeenPwned::PwnedPasswords.check("MyV3ry$$tr0ngP@ssw0rd!2024XYZ"); \
		puts "  → Found #{count} times #{count == 0 ? "✓ (Safe!)" : "💀 (Compromised!)"}\n\n"; \
		\
		puts "#{"\033[0;33m"}3. Range Search (k-Anonymity)#{"\033[0m"}"; \
		puts "Searching hash prefix \"5BAA6\"..."; \
		results = HaveIBeenPwned::PwnedPasswords.range_search("5BAA6"); \
		lines = results.split("\n").count; \
		puts "  → Found #{lines} matching hash suffixes\n\n"; \
		\
		puts "#{"\033[0;33m"}4. Test Account Breach Lookup#{"\033[0m"}"; \
		puts "Using test API key to check opt-out@hibp-integration-tests.com..."; \
		client = HaveIBeenPwned::Client.new( \
			api_key: "00000000000000000000000000000000", \
			user_agent: "HaveIBeenPwned Demo/1.0" \
		); \
		begin; \
			breaches = client.breached_account("opt-out@hibp-integration-tests.com"); \
			puts "  → Found breaches: #{breaches.length}"; \
		rescue HaveIBeenPwned::NotFoundError; \
			puts "  → Account not found in breaches ✓ (Expected for opt-out account)"; \
		end; \
		\
		puts "\n#{"\033[0;32m"}✓ Demo completed!#{"\033[0m"}"; \
		puts "Try: make console (to experiment interactively)"; \
	'

# Demo Pwned Passwords functionality only
# Quick demonstration of password checking without API key
demo-passwords: deps
	@echo "$(CYAN)Pwned Passwords Demo$(NC)"
	@echo ""
	@$(RUBY) -Ilib -r haveibeenpwned -e ' \
		passwords = ["password", "123456", "qwerty", "MyV3ry$$tr0ngP@ss!2024"]; \
		passwords.each do |pwd|; \
			count = HaveIBeenPwned::PwnedPasswords.check(pwd); \
			status = count == 0 ? "#{"\033[0;32m"}✓ SAFE#{"\033[0m"}" : "#{"\033[0;31m"}✗ PWNED (#{count} times)#{"\033[0m"}"; \
			puts "  \"#{pwd}\": #{status}"; \
		end \
	'

# Demo breach lookups with test accounts
# Shows how to query for account breaches using test accounts
demo-breaches: deps
	@echo "$(CYAN)Breach Lookup Demo (Using Test Accounts)$(NC)"
	@echo ""
	@$(RUBY) -Ilib -r haveibeenpwned -e ' \
		client = HaveIBeenPwned::Client.new( \
			api_key: "00000000000000000000000000000000", \
			user_agent: "Demo/1.0" \
		); \
		\
		accounts = [ \
			"opt-out", \
			"account-exists", \
			"multiple-breaches" \
		]; \
		\
		accounts.each do |account|; \
			email = "#{account}@hibp-integration-tests.com"; \
			puts "Checking: #{email}"; \
			begin; \
				breaches = client.breached_account(email); \
				puts "  → Found in #{breaches.length} breach(es): #{breaches.map{|b| b["Name"]}.join(", ")}"; \
			rescue HaveIBeenPwned::NotFoundError; \
				puts "  → Not found in any breaches ✓"; \
			rescue => e; \
				puts "  → Error: #{e.class.name}"; \
			end; \
			puts ""; \
		end \
	'

# Demo error handling
# Shows how different error conditions are handled
demo-errors: deps
	@echo "$(CYAN)Error Handling Demo$(NC)"
	@echo ""
	@$(RUBY) -Ilib -r haveibeenpwned -e ' \
		client = HaveIBeenPwned::Client.new( \
			api_key: "00000000000000000000000000000000", \
			user_agent: "Demo/1.0" \
		); \
		\
		puts "1. NotFoundError (Account not in breaches):"; \
		begin; \
			client.breached_account("opt-out@hibp-integration-tests.com"); \
		rescue HaveIBeenPwned::NotFoundError => e; \
			puts "  → Caught: #{e.class.name}"; \
			puts "  → Message: Account not found (this is good!)"; \
		end; \
		\
		puts "\n2. Error Inheritance:"; \
		puts "  → All errors inherit from HaveIBeenPwned::Error"; \
		puts "  → BadRequestError < Error"; \
		puts "  → UnauthorizedError < Error"; \
		puts "  → ForbiddenError < Error"; \
		puts "  → NotFoundError < Error"; \
		puts "  → RateLimitError < Error (with retry_after attribute)"; \
		puts "  → ServiceUnavailableError < Error"; \
	'

# ----------------------------------------------------------------------------
# Development Tools
# ----------------------------------------------------------------------------

# Start an interactive Ruby console with the gem loaded
# Useful for experimenting with the API interactively
console: deps
	@echo "$(CYAN)Starting interactive console...$(NC)"
	@echo "$(YELLOW)Tip: The gem is already loaded. Try:$(NC)"
	@echo "  HaveIBeenPwned::PwnedPasswords.check('password')"
	@echo ""
	@$(RUBY) -Ilib -r haveibeenpwned -r irb -e 'IRB.start'

# Run RuboCop linter
# Checks code style and potential issues
lint:
	@if command -v rubocop >/dev/null 2>&1; then \
		echo "$(CYAN)Running RuboCop linter...$(NC)"; \
		rubocop; \
	else \
		echo "$(YELLOW)RuboCop not installed. Install with: gem install rubocop$(NC)"; \
	fi

# Auto-format code with RuboCop
# Automatically fixes style issues
format:
	@if command -v rubocop >/dev/null 2>&1; then \
		echo "$(CYAN)Auto-formatting code...$(NC)"; \
		rubocop -a; \
		echo "$(GREEN)✓ Code formatted$(NC)"; \
	else \
		echo "$(YELLOW)RuboCop not installed. Install with: gem install rubocop$(NC)"; \
	fi

# Generate YARD documentation
# Creates HTML documentation from code comments
docs:
	@if command -v yard >/dev/null 2>&1; then \
		echo "$(CYAN)Generating documentation...$(NC)"; \
		yard doc; \
		echo "$(GREEN)✓ Documentation generated in $(DOCS_DIR)/$(NC)"; \
		echo "$(GREEN)  Open $(DOCS_DIR)/index.html to view$(NC)"; \
	else \
		echo "$(YELLOW)YARD not installed. Install with: gem install yard$(NC)"; \
	fi

# ----------------------------------------------------------------------------
# Information & Utilities
# ----------------------------------------------------------------------------

# Display current version
# Shows the gem version from version.rb
version:
	@echo "$(CYAN)HaveIBeenPwned Gem Version:$(NC) $(GREEN)$(VERSION)$(NC)"

# Display comprehensive information about the gem and environment
# Useful for debugging and support requests
info: version
	@echo ""
	@echo "$(CYAN)Gem Information:$(NC)"
	@echo "  Name:          $(GEM_NAME)"
	@echo "  Version:       $(VERSION)"
	@echo "  Gem File:      $(GEM_FILE)"
	@echo ""
	@echo "$(CYAN)Environment:$(NC)"
	@echo "  Ruby Version:  $$($(RUBY) -v)"
	@echo "  Bundler:       $$($(BUNDLE) -v)"
	@echo "  Platform:      $$(uname -s) $$(uname -m)"
	@echo ""
	@echo "$(CYAN)Paths:$(NC)"
	@echo "  Build Dir:     $(BUILD_DIR)/"
	@echo "  Docs Dir:      $(DOCS_DIR)/"
	@echo ""
	@echo "$(CYAN)Dependencies:$(NC)"
	@if [ -f Gemfile.lock ]; then \
		echo "  Status:        ✓ Installed"; \
		$(BUNDLE) list | grep -E "^\s+\*" | head -5; \
		echo "  (run 'bundle list' for full list)"; \
	else \
		echo "  Status:        ✗ Not installed (run 'make deps')"; \
	fi

# ----------------------------------------------------------------------------
# Release Management (for maintainers)
# ----------------------------------------------------------------------------

# Tag and push a new release
# Creates a git tag and pushes to remote
release: test build
	@echo "$(CYAN)Creating release $(VERSION)...$(NC)"
	@echo "$(YELLOW)This will:$(NC)"
	@echo "  1. Create git tag v$(VERSION)"
	@echo "  2. Push tag to origin"
	@echo "  3. Build gem package"
	@echo ""
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		git tag -a v$(VERSION) -m "Release v$(VERSION)"; \
		git push origin v$(VERSION); \
		echo "$(GREEN)✓ Release v$(VERSION) tagged and pushed$(NC)"; \
		echo "$(YELLOW)Next: Push gem to RubyGems with 'gem push $(BUILD_DIR)/$(GEM_FILE)'$(NC)"; \
	else \
		echo "$(RED)Release cancelled$(NC)"; \
	fi

# ----------------------------------------------------------------------------
# Composite Targets
# ----------------------------------------------------------------------------

# Run all checks before committing
# Comprehensive validation target
all: clean deps test lint build
	@echo "$(GREEN)✓ All checks passed!$(NC)"

# Continuous Integration target
# Runs the same checks as CI/CD pipeline
ci: deps test
	@echo "$(GREEN)✓ CI checks passed!$(NC)"

# ----------------------------------------------------------------------------
# Advanced Examples
# ----------------------------------------------------------------------------
# These targets demonstrate advanced Makefile techniques

# Example of conditional execution based on environment
dev-setup:
	@if [ "$$CI" = "true" ]; then \
		echo "$(CYAN)Running in CI environment$(NC)"; \
		$(BUNDLE) install --deployment; \
	else \
		echo "$(CYAN)Running in development environment$(NC)"; \
		$(BUNDLE) install; \
	fi

# Example of parallel execution (if your make supports it)
# Run multiple test suites in parallel
test-parallel:
	@echo "$(CYAN)Running tests in parallel...$(NC)"
	@$(BUNDLE) exec rake test & \
	$(RUBY) -Ilib:test test/errors_test.rb & \
	wait
	@echo "$(GREEN)✓ Parallel tests completed$(NC)"

# ============================================================================
# End of Makefile
# ============================================================================
# For more information about GNU Make:
#   https://www.gnu.org/software/make/manual/
#
# For Ruby gem development:
#   https://guides.rubygems.org/
# ============================================================================
