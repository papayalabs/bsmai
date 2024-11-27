require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get register_url
    assert_response :success
  end

  test "should create user" do
    post users_url, params: {user: user_attr}
    assert_response :redirect
    follow_redirect!
    follow_redirect! # intentionally two redirects
    assert_response :success
  end

  test "it should redirect back when the email address is already in use" do
    email = users(:manuel).email
    post users_url, params: {user: user_attr.merge(email: email)}
    assert_response :unprocessable_entity
    assert_match "Email has already been taken", response.body
  end

  test "it should show an error message when the password is blank" do
    post users_url, params: {user: user_attr.merge(password: "")}
    assert_response :unprocessable_entity
    assert_match "Password can&#39;t be blank", response.body
  end

  test "it should show an error message when the email is blank" do
    post users_url, params: {user: user_attr.merge(email: "")}
    assert_response :unprocessable_entity
    assert_match "Email can&#39;t be blank", response.body
  end

  test "after create, an account should be bootstrapped and taken to a conversation" do
    email = "fake_email#{rand(1000)}@example.com"
    post users_url, params: {user: user_attr.merge(email: email)}

    user = User.find_by(email: email)
    assert_equal "John", user.first_name
    assert_equal "Doe", user.last_name
    assert_equal 4, user.assistants.count, "This new user did not get the expected number of assistants"

    assistant = user.assistants.ordered.first

    follow_redirect!
    assert_redirected_to new_assistant_message_path(assistant)
  end

  private

  def user_attr
    { password: "secret", name: "John Doe" }
  end
end
