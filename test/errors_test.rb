# frozen_string_literal: true

require_relative "test_helper"

class ErrorsTest < Minitest::Test
  def test_error_inheritance_structure
    assert HaveIBeenPwned::BadRequestError < HaveIBeenPwned::Error
    assert HaveIBeenPwned::UnauthorizedError < HaveIBeenPwned::Error
    assert HaveIBeenPwned::ForbiddenError < HaveIBeenPwned::Error
    assert HaveIBeenPwned::NotFoundError < HaveIBeenPwned::Error
    assert HaveIBeenPwned::RateLimitError < HaveIBeenPwned::Error
    assert HaveIBeenPwned::ServiceUnavailableError < HaveIBeenPwned::Error
  end

  def test_rate_limit_error_has_retry_after
    error = HaveIBeenPwned::RateLimitError.new("Test", retry_after: 10)

    assert_equal 10, error.retry_after
    assert_equal "Test", error.message
  end

  def test_rate_limit_error_without_retry_after
    error = HaveIBeenPwned::RateLimitError.new("Test")

    assert_nil error.retry_after
    assert_equal "Test", error.message
  end
end
