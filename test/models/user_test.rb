require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "has a last_cancelled_message but can be nil" do
    assert_equal messages(:dont_know_day), users(:manuel).last_cancelled_message
    assert_nil users(:rob).last_cancelled_message
  end

  test "should not validate a new user without password" do
    user = User.new(email: "example@gmail.com")
    refute user.valid?
  end

  test "should validate a user with minimum information" do
    user = User.new(email: "example@gmail.com", password: "password", password_confirmation: "password", first_name: "John", last_name: "Doe")
    assert user.valid?
  end

  test "should validate presence of first name" do
    user = users(:manuel)
    user.update(first_name: nil)
    refute user.valid?
    assert_equal ["can't be blank"], user.errors[:first_name]
  end

  test "although last name is required for create it's not required for update" do
    assert_nothing_raised do
      users(:manuel).update!(last_name: nil)
    end
  end

  test "it can update a user with a password" do
    user = users(:manuel)
    old_password_hash = user.password_digest
    user.update(password: "password")
    assert user.valid?
    refute_equal old_password_hash, user.password_digest
  end

  test "it can update a user without a password" do
    user = users(:manuel)
    old_password_hash = user.password_digest
    user.update(first_name: "New Name")
    assert user.valid?
    assert_equal old_password_hash, user.password_digest
  end

  test "passwords must be 6 characters or longer" do
    user = User.new(first_name: "John", last_name: "Doe")
    bad_short_passwords = ["", "12345"]

    bad_short_passwords.each do |bad_password|
      user.password = bad_password
      user.valid?
      assert user.errors[:password].present?
    end

    good_password = "123456"
    user.password = good_password
    assert user.valid?
    refute user.errors[:password].present?
  end

  test "it can validate a password" do
    user = users(:manuel)
    assert user.authenticate("secret")
  end

  test "it destroys assistantes on destroy" do
    assistant = assistants(:samantha)
    assistant.user.destroy
    assert_raises ActiveRecord::RecordNotFound do
      assistant.reload
    end
  end

  test "it destroys conversations on destroy" do
    conversation = conversations(:greeting)
    conversation.user.destroy
    assert_raises ActiveRecord::RecordNotFound do
      conversation.reload
    end
  end

  test "boolean values within preferences get converted back and forth properly" do
    assert_nil users(:manuel).preferences[:nav_closed]
    assert_nil users(:manuel).preferences[:kids]
    assert_nil users(:manuel).preferences[:city]

    users(:manuel).update!(preferences: {
      nav_closed: true,
      kids: 2,
      city: "Austin"
    })
    users(:manuel).reload

    assert users(:manuel).preferences[:nav_closed]
    assert_equal 2, users(:manuel).preferences[:kids]
    assert_equal "Austin", users(:manuel).preferences[:city]

    users(:manuel).update!(preferences: {
      nav_closed: "false",

    })

    refute users(:manuel).preferences[:nav_closed]

  end

  test "dark_mode preference defaults to system and it can update user dark_mode preference" do
    new_user = User.create!(password: 'password', first_name: 'First', last_name: 'Last')
    assert_equal "system", new_user.preferences[:dark_mode]

    new_user.update!(preferences: { dark_mode: "light" })
    assert_equal "light", new_user.preferences[:dark_mode]

    new_user.update!(preferences: { dark_mode: "dark" })

    assert_equal "dark", new_user.preferences[:dark_mode]

    new_user.update!(preferences: { dark_mode: "system" })

    assert_equal "system", new_user.preferences[:dark_mode]

  end

end
