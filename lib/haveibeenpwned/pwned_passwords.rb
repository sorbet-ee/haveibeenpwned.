# frozen_string_literal: true

require "faraday"
require "digest"

module HaveIBeenPwned
  class PwnedPasswords
    BASE_URL = "https://api.pwnedpasswords.com"

    class << self
      def check(password, mode: :sha1, padding: false)
        hash = hash_password(password, mode)
        check_hash(hash, mode: mode, padding: padding)
      end

      def check_hash(hash, mode: :sha1, padding: false)
        hash = hash.upcase
        prefix = hash[0..4]
        suffix = hash[5..-1]

        response = range_search(prefix, mode: mode, padding: padding)

        # Parse response and find matching suffix
        response.each_line do |line|
          hash_suffix, count = line.strip.split(":")
          return count.to_i if hash_suffix == suffix
        end

        0
      end

      def range_search(prefix, mode: :sha1, padding: false)
        params = {}
        params[:mode] = mode.to_s if mode == :ntlm

        headers = {}
        headers["Add-Padding"] = "true" if padding

        response = connection.get("/range/#{prefix}", params) do |req|
          headers.each { |key, value| req.headers[key] = value }
        end

        raise Error, "Unexpected response: #{response.status}" unless response.status == 200

        response.body
      end

      private

      def connection
        @connection ||= Faraday.new(url: BASE_URL) do |conn|
          conn.adapter Faraday.default_adapter
        end
      end

      def hash_password(password, mode)
        case mode
        when :sha1
          Digest::SHA1.hexdigest(password)
        when :ntlm
          # NTLM hashing would require additional gem, keeping simple for now
          raise NotImplementedError, "NTLM hashing not yet implemented. Use check_hash with pre-computed NTLM hash."
        else
          raise ArgumentError, "Invalid mode: #{mode}. Use :sha1 or :ntlm"
        end
      end
    end
  end
end
