# frozen_string_literal: true

require_relative "robodash/version"

module Robodash
  class Error < StandardError; end

  class << self
    attr_accessor :api_token

    def ping(name)
      send_request("ping", {name: name})
    end

    # Count should always be an integer
    def count(name, count)
      send_request("count", {name: name, count: count.to_i})
    end

    private

      def send_request(endpoint, body)
        raise "API token is not set!" unless api_token

        begin
          Thread.new do
            uri = URI("https://beta.robodash.app/api/#{endpoint}.json")
            request = Net::HTTP::Post.new(uri)
            request["Authorization"] = "dashboard-token #{api_token}"
            request["Content-Type"] = "application/json"
            request.body = body.to_json

            Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
              http.open_timeout = 5
              http.read_timeout = 10
              http.request(request)
            end
          end
          true
        rescue StandardError => e
          warn "Failed to ping Robodash: #{e.message}"
          false
        end
      end

  end
end

