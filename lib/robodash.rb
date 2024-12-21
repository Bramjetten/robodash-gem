# frozen_string_literal: true

require_relative "robodash/version"

module Robodash
  # Defaults
  DEFAULT_HOST = "https://beta.robodash.app"
  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 10

  class << self
    attr_accessor :api_token, :host

    def ping(name)
      post("ping", {name: name})
    end

    # Count should always be an integer
    def count(name, count)
      post("count", {name: name, count: count.to_i})
    end

    private

      def post(endpoint, body)
        raise "API token is not set!" unless api_token

        begin
          Thread.new do
            # URI is always on the /api/ endpoint right now
            uri = URI("#{host}/api/#{endpoint}.json")

            # Build a new POST request with Net::HTTP
            # Always a JSON-request
            request = Net::HTTP::Post.new(uri)
            request["Authorization"] = "dashboard-token #{api_token}"
            request["Content-Type"] = "application/json"
            request.body = body.to_json

            send_request(uri, request)
          end
          true
        rescue StandardError => e
          # If something goes wrong, just show that message
          warn "Failed to ping Robodash: #{e.message}"
          false
        end
      end

      def send_request(uri, request)
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
          http.open_timeout = OPEN_TIMEOUT
          http.read_timeout = READ_TIMEOUT
          http.request(request)
        end
      end

      def host
        @host || DEFAULT_HOST
      end

  end
end

