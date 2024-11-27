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
      @client = self.class.client.new(
        credentials: { address: assistant.api_url },
        options: { server_sent_events: true }
      )
    rescue ::Faraday::UnauthorizedError => e
      raise Faraday::UnauthorizedError
    end
    @assistant = assistant
    @conversation = conversation
    @message = message
  end

  def client_method_name
    :chat
  end

  def configuration_error
    ::OpenAI::ConfigurationError
  end

  def set_client_config(config)
    @client_config = {
      model: @assistant.model,
      messages: config[:messages] + config[:instructions]
    }
  end

  def get_oneoff_message(instructions, messages, params = {})
    set_client_config(
        messages: preceding_messages,
        instructions: system_message,
      )
    begin
      response_text = ""
      @client.send(client_method_name, @client_config) do |event, raw|
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

  def get_next_chat_message(&chunk_handler)
    set_client_config(
      messages: preceding_messages,
      instructions: system_message,
    )
    begin
      # Systeem instruction is not working well on gem 'gemini-ai'
      #response = @client.stream_generate_content({contents: preceding_messages,system_instruction: system_message})
      #response = @client.stream_generate_content({contents: preceding_messages})
      response = @client.send(client_method_name, @client_config) do |event, raw|
        yield event["message"]["content"]
      end
     rescue ::Faraday::UnauthorizedError => e
       puts e.message
       raise OpenAI::ConfigurationError
    end
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