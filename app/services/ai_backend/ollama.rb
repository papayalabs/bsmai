class AIBackend::Ollama
  attr :client

  # Rails system tests don't seem to allow mocking because the server and the
  # test are in separate processes.
  #
  # In regular tests, mock this method or the TestClients::OpenAI class to do
  # what you want instead.
  def self.client
    if Rails.env.test?
      TestClients::Ollama
    else
      Ollama
    end
  end

  def initialize(user, assistant, conversation, message)
    begin
      #@client = self.class.client.new(access_token: user.openai_key)
      @client = self.class.client.new(
        credentials: { address: 'http://localhost:11434' },
        options: { server_sent_events: true }
      )
    rescue ::Faraday::UnauthorizedError => e
      raise Faraday::UnauthorizedError
    end
    @assistant = assistant
    @conversation = conversation
    @message = message
  end

  def get_oneoff_message(instructions, messages, params = {})
    begin
      response = @client.chat({ model: 'llama3.2',messages: system_message + preceding_messages })
      response_text = ""
      response.each do |event, raw|
        response_text += event["message"]["content"]
      end
      return response_text
    rescue ::Faraday::UnauthorizedError => e
      raise Faraday::UnauthorizedError
    end

    if response_text.blank? #&& stream_response_text.blank?
      raise ::Faraday::ParsingError
    else
      response_text
    end
  end

  def get_next_chat_message(&chunk_received_handler)
    begin
      response = @client.chat({ model: @assistant.model,messages: system_message + preceding_messages })
    rescue ::Faraday::UnauthorizedError => e
      raise Faraday::UnauthorizedErrors
    end
    return response.map { |h| h["message"]["content"] }
  end

  private

  def system_message
    return [] if @assistant.instructions.blank?

    [{
      role: 'system',
      content: @assistant.instructions
    }]
  end

  def preceding_messages
    @conversation.messages.for_conversation_version(@message.version).where("messages.index < ?", @message.index).collect do |message|
      if @assistant.images && message.documents.present?

        content = [{ type: "text", text: message.content_text }]
        content += message.documents.collect do |document|
          { type: "image_url", image_url: { url: document.file_data_url(:large) }}
        end

        {
          role: message.role,
          content: content
        }
      else
        {
          role: message.role,
          content: message.content_text || ""
        }
      end
    end
  end
end