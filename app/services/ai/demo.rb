# frozen_string_literal: true

module Ai
  # Canned-reply provider so the whole app works offline with zero keys.
  # Picks a reply from the user's last message so demos feel alive, and
  # yields it in word-sized chunks so the streaming UI is exercised for real.
  class Demo < Provider
    REPLIES = [
      "That's a good question. The short answer is that Emberline keeps every reply inside the conversation, so you can pick up exactly where you left off. The long answer is that it depends on what you're trying to build — but I'd start with the simplest version that still answers the question, then add surface area only when the first one breaks.",
      "Here's how I'd think about it. First, name the smallest version of the outcome that would count as success. Second, sketch the fewest moving parts that could produce it. Third, run that and look at what actually happened instead of what you predicted. Most of the time the gap between two and three is where the real design lives.",
      "I can help with that. A useful framing: you're not choosing between options, you're choosing which constraints you're willing to keep. List the three you refuse to give up and the rest of the decision mostly makes itself. Want me to walk through your specific case?"
    ].freeze

    PREFIXES = [
      "Emberline demo mode: ",
      "Demo reply: ",
      "From the offline demo provider: "
    ].freeze

    def stream(messages)
      last_user = messages.reverse.find { |m| m[:role] == "user" }
      reply = REPLIES.fetch(last_user.to_s.length % REPLIES.size)
      reply = PREFIXES.fetch(reply.length % PREFIXES.size) + reply if preview?(last_user)
      reply.split(/(\s+)/).each { |chunk| yield chunk }
    end

    private

    def preview?(last_user)
      return true unless last_user

      last_user.fetch(:content, "").match?(/\bdemo\b/i)
    end
  end
end
