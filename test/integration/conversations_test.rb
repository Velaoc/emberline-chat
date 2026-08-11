require "test_helper"

class ConversationsIntegrationTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess

  setup do
    @user = users(:confirmed)
    sign_in @user
  end

  test "signed-in user can create a conversation" do
    assert_difference "Conversation.count", 1 do
      post conversations_path
    end
    assert_response :created
    conversation = Conversation.order(:id).last
    assert_equal @user, conversation.user
    assert_equal "New chat", conversation.title
  end

  test "guest is redirected to sign in" do
    sign_out @user
    get conversations_path
    assert_redirected_to new_user_session_path
  end

  test "user only sees their own conversations" do
    mine = Conversation.create!(user: @user, title: "Mine")
    other = Conversation.create!(user: users(:admin), title: "Theirs")

    get conversation_path(other)
    assert_redirected_to conversations_path

    get conversation_path(mine)
    assert_response :success
    assert_select "h1", text: "Mine"
  end

  test "user can delete their own conversation" do
    conversation = Conversation.create!(user: @user, title: "Doomed")
    assert_difference "Conversation.count", -1 do
      delete conversation_path(conversation)
    end
    assert_redirected_to root_path
  end
end
