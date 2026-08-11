# frozen_string_literal: true

module Ai
  # Pluggable chat provider. Subclasses implement #stream(messages) and yield
  # text deltas as they arrive. The active provider is chosen at request time
  # from config/foundation.yml (:ai) so a deploy can flip between the canned
  # demo and a real OpenAI-compatible endpoint with no code changes.
  class Provider
    # Returns the configured provider instance. Defaults to the demo so the
    # app works end to end with zero external credentials.
    def self.build(config: Rails.configuration.x.foundation[:ai] || {}, env: ENV)
      case config[:provider].to_s
      when "openai_compatible"
        OpenAiCompatible.new(config: config[:openai_compatible] || {}, env: env)
      else
        Demo.new
      end
    end

    # Yields successive String chunks of the assistant reply. Messages are
    # an array of { role:, content: } hashes, oldest first.
    def stream(_messages)
      raise NotImplementedError, "#{self.class} must implement #stream"
    end

    def provider_name
      self.class.name.demodulize.underscore
    end
  end
end
