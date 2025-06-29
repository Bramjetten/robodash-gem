# frozen_string_literal: true

require_relative "robodash/version"
require "net/http"
require "uri"
require "json"

module Robodash
  # Defaults
  DEFAULT_HOST = "https://robodash.app"
  OPEN_TIMEOUT = 2
  READ_TIMEOUT = 5

  class << self
    attr_accessor :api_token, :host, :enabled

    def enabled?
      return true if @enabled.nil?
      @enabled
    end

    # Possible schedules:
    # - minutely
    # - hourly
    # - daily
    # - weekly
    # - monthly
    # - yearly
    def ping(name, schedule_number = 1, schedule_period = "day", grace_period: 1.minute)
      fire_and_forget("ping", {
        name: name, 
        schedule_number: schedule_number,
        schedule_period: schedule_period,
        grace_period: grace_period.to_i
      })
    end

    # Count should always be an integer
    def count(name, count, range = nil)
      fire_and_forget("count", {name: name, count: count.to_i})
    end

    private

      def fire_and_forget(endpoint, body)
        return false unless enabled?
        return false unless api_token

        Thread.new do
          Thread.current.abort_on_exception = false
          
          begin
            send_api_request(endpoint, body)
          rescue => e
            warn_safely("Robodash request failed: #{e.class} - #{e.message}")
          end
        end

        true
      end

      def send_api_request(endpoint, body)
        uri = URI("#{host}/api/#{endpoint}.json")
        
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "dashboard-token #{api_token}"
        request["Content-Type"] = "application/json"
        request.body = body.to_json

        # Use aggressive timeouts for fire-and-forget
        Net::HTTP.start(uri.hostname, uri.port, 
                        use_ssl: uri.scheme == "https",
                        open_timeout: OPEN_TIMEOUT,
                        read_timeout: READ_TIMEOUT,
                        ssl_timeout: OPEN_TIMEOUT) do |http|
          http.request(request)
        end
      end

      # Only warn if we're in a context where it's safe to do so
      def warn_safely(message)
        if defined?(Rails) && Rails.logger
          Rails.logger.warn("[Robodash] #{message}")
        elsif $stderr && !$stderr.closed?
          $stderr.puts("[Robodash] #{message}")
        end
      rescue
        # If even logging fails, just silently continue
      end

      def host
        @host || DEFAULT_HOST
      end

  end
end

