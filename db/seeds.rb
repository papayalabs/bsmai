require "active_record/fixtures"

#if Rails.env.development?
#
#  puts "loading fixtures"
#  order_to_load_fixtures = %w[people users tombstones assistants conversations runs messages steps]
#
#  ActiveRecord::Base.transaction do
#    ActiveRecord::Base.connection.disable_referential_integrity do
#      ActiveRecord::FixtureSet.create_fixtures(Rails.root.join('test', 'fixtures'), order_to_load_fixtures)
#    end
#  end
#end
user = User.new
user.first_name = "Daniel"
user.last_name = "Burns"
user.password = "password"
user.preferences["dark_mode"] = "dark"
user.email = "daniel@boulderseomarketing.com"
user.role = :admin
user.active = true
user.save!

puts user.first_name.to_s+" Created"

user.assistants.create! name: "Meta Llama 3.2", model: "llama3.2", api_protocol: "OLLAMA", api_url: "http://localhost:11434", supports_images: false
user.assistants.create! name: "Gemini Flahs 1.5", model: "gemini-1.5-flash", api_protocol: "GEMINI", api_url: "https://api.gemini.com/v1/", supports_images: true
user.assistants.create! name: "Claude Haiku 3.0", model: "claude-3-haiku-20240307", api_protocol: "ANTHROPIC", api_url: "https://api.anthropic.com/", supports_images: true
user.assistants.create! name: "Perplexity Sonar", model: "llama-3.1-sonar-large-128k-online", api_protocol: "OPEN_AI", api_url: "https://api.perplexity.ai/", supports_images: true
user.assistants.create! name: "ChatGPT 3.5 Turbo", model: "gpt-3.5-turbo", api_protocol: "OPEN_AI", api_url: "https://api.openai.com/v1/", supports_images: true

puts "Assistants Created"


prompt_processes = PromptProcess.new
prompt_processes.name = "New Prompt Process"
prompt_processes.save!

puts "Prompt Process Created"

general_settings = GeneralSetting.new
general_settings.theme_preference = "LIGHT"
general_settings.app_logo = "https://bsmai.s3.us-east-2.amazonaws.com/bsmai.png"
general_settings.app_name = "BSMAI"
general_settings.save!

puts "General Settings Created"