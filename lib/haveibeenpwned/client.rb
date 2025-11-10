# frozen_string_literal: true

require "faraday"
require "json"
require "erb"

module HaveIBeenPwned
  class Client
    BASE_URL = "https://haveibeenpwned.com/api/v3"

    attr_reader :api_key, :user_agent

    def initialize(api_key:, user_agent:)
      @api_key = api_key
      @user_agent = user_agent
    end

    # Breaches

    def breached_account(account, truncate_response: true, domain: nil, include_unverified: true)
      params = {
        truncateResponse: truncate_response,
        includeUnverified: include_unverified
      }
      params[:domain] = domain if domain

      get("/breachedaccount/#{url_encode(account)}", params)
    end

    def breached_domain(domain)
      get("/breacheddomain/#{domain}")
    end

    def subscribed_domains
      get("/subscribeddomains")
    end

    def breaches(domain: nil, is_spam_list: nil)
      params = {}
      params[:domain] = domain if domain
      params[:isSpamList] = is_spam_list unless is_spam_list.nil?

      get("/breaches", params)
    end

    def breach(name)
      get("/breach/#{name}")
    end

    def latest_breach
      get("/latestbreach")
    end

    def data_classes
      get("/dataclasses")
    end

    # Stealer Logs

    def stealer_logs_by_email(email)
      get("/stealerlogsbyemail/#{url_encode(email)}")
    end

    def stealer_logs_by_website_domain(domain)
      get("/stealerlogsbywebsitedomain/#{domain}")
    end

    def stealer_logs_by_email_domain(domain)
      get("/stealerlogsbyemaildomain/#{domain}")
    end

    # Pastes

    def pastes(account)
      get("/pasteaccount/#{url_encode(account)}")
    end

    # Subscription

    def subscription_status
      get("/subscription/status")
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |conn|
        conn.headers["hibp-api-key"] = api_key
        conn.headers["user-agent"] = user_agent
        conn.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      response = connection.get(path, params)
      handle_response(response)
    end

    def handle_response(response)
      case response.status
      when 200
        parse_json(response.body)
      when 400
        raise BadRequestError, parse_error_message(response)
      when 401
        raise UnauthorizedError, parse_error_message(response)
      when 403
        raise ForbiddenError, parse_error_message(response)
      when 404
        raise NotFoundError, parse_error_message(response)
      when 429
        retry_after = response.headers["retry-after"]&.to_i
        raise RateLimitError.new(parse_error_message(response), retry_after: retry_after)
      when 503
        raise ServiceUnavailableError, parse_error_message(response)
      else
        raise Error, "Unexpected response: #{response.status} - #{response.body}"
      end
    end

    def parse_json(body)
      return nil if body.nil? || body.empty?
      JSON.parse(body)
    end

    def parse_error_message(response)
      body = parse_json(response.body)
      body.is_a?(Hash) ? body["message"] || body["statusCode"] : response.body
    rescue JSON::ParserError
      response.body
    end

    def url_encode(string)
      ERB::Util.url_encode(string.to_s.strip)
    end
  end
end
