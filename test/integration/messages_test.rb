require "test_helper"

class MessagesIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:confirmed)
    sign_in @user
    @conversation = Conversation.create!(user: @user, title: "Test chat")
  end

  test "posting a message streams a demo reply and persists both messages" do
    assert_difference "Message.count", 2 do
      post conversation_messages_path(@conversation), params: { message: "Hello there" }
    end
    assert_response :success

    roles = @conversation.messages.order(:created_at).pluck(:role)
    assert_equal %w[user assistant], roles
    assert_equal "Hello there", @conversation.messages.order(:created_at).first.content
    assert @conversation.messages.order(:created_at).last.content.present?
  end

  test "blank message is rejected" do
    assert_no_difference "Message.count" do
      post conversation_messages_path(@conversation), params: { message: "   " }
    end
    assert_response :unprocessable_content
  end

  test "cannot post to another user's conversation" do
    other = Conversation.create!(user: users(:admin), title: "Not mine")
    assert_no_difference "Message.count" do
      post conversation_messages_path(other), params: { message: "sneak" }
    end
    assert_response :not_found
  end

  test "guest cannot post messages" do
    sign_out @user
    post conversation_messages_path(@conversation), params: { message: "hi" }
    assert_redirected_to new_user_session_path
  end
end
