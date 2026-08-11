class MessagesController < ApplicationController
  before_action :authenticate_user!

  # Appends the user's message, then streams the assistant reply back over
  # the same response. The provider yields text deltas; each one is flushed
  # to the client and accumulated; the completed reply is persisted. If the
  # provider raises mid-stream the partial text is still saved so the
  # conversation stays coherent.
  def create
    conversation = Conversation.for_user(current_user).find_by(id: params[:conversation_id])
    unless conversation
      return head :not_found
    end

    content = params[:message].to_s.strip
    return head :unprocessable_content if content.blank?

    conversation.messages.create!(role: "user", content: content)

    provider = Ai::Provider.build
    buffer = +""
    response.headers["X-Accel-Buffering"] = "no"

    begin
      provider.stream(conversation.context_messages) do |chunk|
        buffer << chunk
        response.stream.write chunk
      end
    rescue StandardError => e
      buffer << "\n\n[provider error: #{e.message}]"
      response.stream.write "\n\n[provider error: #{e.message}]"
    ensure
      conversation.messages.create!(role: "assistant", content: buffer) if buffer.present?
      response.stream.close
    end
  end
end
