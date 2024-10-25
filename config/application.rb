require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BSMAI
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # To remove in 2025. This allows migration db/migrate/20240415134849_encrypt_keys.rb to encrypt existing plaintext keys
    config.active_record.encryption.support_unencrypted_data = true

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.eager_load_paths << Rails.root.join("lib")

    config.features = config_for(:features)
    config.hosts << "bsmoutlinegenerator.papayalabs.io"
    config.hosts << "chat.papayalabs.io"
    config.hosts << "52.40.191.155"
    config.hosts << "bsmbrain.live"
  end
end
