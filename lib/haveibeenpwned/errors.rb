# frozen_string_literal: true

module HaveIBeenPwned
  class Error < StandardError; end

  class BadRequestError < Error; end

  class UnauthorizedError < Error; end

  class ForbiddenError < Error; end

  class NotFoundError < Error; end

  class RateLimitError < Error
    attr_reader :retry_after

    def initialize(message, retry_after: nil)
      super(message)
      @retry_after = retry_after
    end
  end

  class ServiceUnavailableError < Error; end
end
