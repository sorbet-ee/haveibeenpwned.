# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "haveibeenpwned"
require "minitest/autorun"
require "webmock/minitest"

# Test constants
TEST_API_KEY = "00000000000000000000000000000000"
TEST_USER_AGENT = "HaveIBeenPwned Ruby Gem Tests/1.0"
TEST_DOMAIN = "hibp-integration-tests.com"

# Helper module for tests
module TestHelpers
  def hibp_client
    @hibp_client ||= HaveIBeenPwned::Client.new(
      api_key: TEST_API_KEY,
      user_agent: TEST_USER_AGENT
    )
  end

  def hibp_test_account(alias_name)
    "#{alias_name}@#{TEST_DOMAIN}"
  end
end
