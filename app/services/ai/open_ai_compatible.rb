# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Ai
  # Streaming client for any OpenAI-compatible chat completions endpoint
  # (OpenAI, DeepSeek, OpenRouter, Together, local vLLM/Ollama…). Everything
  # is configured through environment variables or config/foundation.yml — the
  # only thing a deploy must supply is a real API key.
  #
  #   AI_PROVIDER=openai_compatible
  #   AI_BASE_URL=https://api.openai.com/v1
  #   AI_API_KEY=sk-...
  #   AI_MODEL=gpt-4o-mini
  #
  # If AI_BASE_URL/AI_MODEL are absent it falls back to the foundation.yml
  # ai.openai_compatible block (base_url/model), which makes the real provider
  # fully wired but inert until a key is set: requests without a key fail
  # loudly with a clear message rather than silently returning canned text.
  class OpenAiCompatible < Provider
    TIMEOUT_SECONDS = 120

    def initialize(config: {}, env: ENV)
      @base_url = env["AI_BASE_URL"].presence || config[:base_url]
      @api_key = env["AI_API_KEY"].presence
      @model = env["AI_MODEL"].presence || config[:model]
      @timeout = Integer(env.fetch("AI_TIMEOUT_SECONDS", TIMEOUT_SECONDS))
    end

    def stream(messages)
      raise "AI_API_KEY is not set — configure a real key to use the live provider" if @api_key.blank?

      uri = URI.join(@base_url.to_s, "chat/completions")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = @timeout
      http.open_timeout = @timeout

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Content-Type"] = "application/json"
      request["Accept"] = "text/event-stream"
      request.body = JSON.generate(
        model: @model,
        messages: messages,
        stream: true
      )

      http.request(request) do |response|
        unless response.is_a?(Net::HTTPOK)
          raise "AI provider error: HTTP #{response.code} #{response.message}"
        end

        response.read_body do |chunk|
          chunk.split("\n").each do |line|
            next unless line.start_with?("data: ")

            payload = line.delete_prefix("data: ").strip
            next if payload == "[DONE]"

            delta = JSON.parse(payload).dig("choices", 0, "delta", "content")
            yield delta if delta.present?
          end
        end
      end
    rescue JSON::ParserError => e
      raise "AI provider returned malformed stream data: #{e.message}"
    end
  end
end
