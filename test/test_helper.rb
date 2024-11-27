ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "pry"

Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |file| require file }

class Capybara::Node::Element
  def obsolete?
    inspect.include?('Obsolete')
  end

  def exists?
    !obsolete?
  end
end

class ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers

  Capybara.default_max_wait_time = 8

  def login_as(user)
    post login_path, params: { email: user.email, password: "secret" }
    assert_response :redirect
    follow_redirect!
    follow_redirect!
    assert_response :success
  end
end

module ActiveSupport
  class TestCase
    include Turbo::Broadcastable::TestHelper
    include ActiveJob::TestHelper

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Added this ActiveStorage configuration when implementing postgres-file storage
    setup do
      if ActiveStorage::Current.respond_to?(:url_options)
        ActiveStorage::Current.url_options = { host: 'example.com', protocol: 'https' }
      else
        ActiveStorage::Current.host = "https://example.com"
      end
    end

    teardown do
      ActiveStorage::Current.reset
    end
  end
end