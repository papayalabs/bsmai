require "test_helper"

class User::RegisterableTest < ActiveSupport::TestCase
  test "it creates an assistant and a coversation when valid" do
    user = User.new(email: "example@gmail.com", password: "password", first_name: "John", last_name: "Doe")

    assert user.save
    assert_instance_of Assistant, user.assistants.first
  end
end
