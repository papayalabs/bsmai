module User::Registerable
  extend ActiveSupport::Concern

  included do
    after_create :create_initial_assistants
  end

  private

  def create_initial_assistants
   # assistants.create! name: "Ollama Llama 3.2", model: "llama3.2", images: true
    assistants.create! name: "Gemini", model: "gemini-1.5-flash", images: true
  end
end
