module User::Registerable
  extend ActiveSupport::Concern

  included do
    after_create :create_initial_assistants
  end

  private

  def create_initial_assistants
    assistants.create! name: "Ollama Llama 3.2", model: "llama3.2", api_url: "http://localhost:11434", images: false
    assistants.create! name: "Gemini Flahs 1.5", model: "gemini-1.5-flash", api_url: "https://api.gemini.com/v1/", images: true
    assistants.create! name: "Claude Haiku 3.0", model: "claude-3-haiku-20240307", api_url: "https://api.anthropic.com/", images: true
  end
end