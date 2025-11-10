# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
  include TestHelpers

  def test_client_initialization
    client = HaveIBeenPwned::Client.new(
      api_key: TEST_API_KEY,
      user_agent: TEST_USER_AGENT
    )

    assert_equal TEST_API_KEY, client.api_key
    assert_equal TEST_USER_AGENT, client.user_agent
  end

  def test_client_has_breach_methods
    client = hibp_client

    assert_respond_to client, :breached_account
    assert_respond_to client, :breached_domain
    assert_respond_to client, :breaches
    assert_respond_to client, :breach
    assert_respond_to client, :latest_breach
    assert_respond_to client, :data_classes
  end

  def test_client_has_stealer_log_methods
    client = hibp_client

    assert_respond_to client, :stealer_logs_by_email
    assert_respond_to client, :stealer_logs_by_website_domain
    assert_respond_to client, :stealer_logs_by_email_domain
  end

  def test_client_has_paste_methods
    client = hibp_client

    assert_respond_to client, :pastes
  end

  def test_client_has_subscription_methods
    client = hibp_client

    assert_respond_to client, :subscription_status
    assert_respond_to client, :subscribed_domains
  end
end
