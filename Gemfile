# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.0"

gem "rails", "~> 7.1.3"
gem "sprockets-rails" # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "pg", "~> 1.5.9"
gem "puma", ">= 6.0"
gem "importmap-rails" # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "turbo-rails", "~> 2.0.5"
gem "stimulus-rails"
gem "tailwindcss-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mri mingw x64_mingw]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "redcarpet", "~> 3.6.0"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

gem "rails_heroicon", "~> 2.2.0"

gem "tiktoken_ruby", "~> 0.0.6"
gem "solid_queue", "~> 1.1.4"
gem "name_of_person"
gem "actioncable-enhanced-postgresql-adapter" # longer paylaods w/ postgresql actioncable

#group :production do
#  gem "puma-daemon"
#end
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "timecop"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "pry-rails"
  gem "standard"
  gem "ruby-lsp"
  gem "rubocop-rails"
  gem "rubocop-capybara"
  gem "rubocop-minitest"
  gem "dockerfile-rails", ">= 1.6"
end

group :development do
  gem 'sqlite3'
  gem 'better_errors'
  gem 'rails_layout'
  gem 'listen'
  #Add Capistrano for deploy
  gem "capistrano", "~> 3.10", require: false
  gem 'capistrano-bundler', '~> 1.5'
  gem "capistrano-rails", "~> 1.4", require: false
  gem 'capistrano-rails-console', require: false
  gem 'capistrano-rake', require: false
  gem 'capistrano-rvm', require: false
  #gem "capistrano3-puma", github: "seuros/capistrano-puma"
  gem 'sshkit-sudo'
  gem 'capistrano3-unicorn'
  gem 'pry'
  gem 'pry-byebug'
  gem 'erd'
end
group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "minitest-stub_any_instance"
end

#AI Libraries

gem "ruby-openai", "~> 7.0.1"
gem "anthropic", "~> 0.1.0"
gem 'ollama-ai', '~> 1.3.0'
gem 'gemini-ai', '~> 4.2.0'

#Daemons for Solid Queue
gem 'daemons'
gem 'foreman'
gem "roo", "~> 2.10.0"

gem 'acts_as_list'
gem 'google-apis-drive_v3'

#For Capistrano SSH
gem 'net-ssh', '>= 6.0.2'
gem 'ed25519', '>= 1.2', '< 2.0'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'