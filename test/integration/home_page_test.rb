require "test_helper"

class HomePageTest < ActionDispatch::IntegrationTest
  test "guest sees the Emberline landing page" do
    get root_path

    assert_response :success
    assert_select "h1", text: /A chat that keeps every thread/
    assert_select "a[href='#{new_user_registration_path}']", minimum: 1
    assert_select "a[href='#{new_user_session_path}']", minimum: 1
  end

  test "signed-in users are sent straight into chat" do
    sign_in users(:confirmed)
    get root_path

    assert_redirected_to conversations_path
  end
end
