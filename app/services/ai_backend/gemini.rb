class AIBackend::Gemini
  attr :client

  # Rails system tests don't seem to allow mocking because the server and the
  # test are in separate processes.
  #
  # In regular tests, mock this method or the TestClients::OpenAI class to do
  # what you want instead.
  def self.client
    if Rails.env.test?
      TestClients::Gemini
    else
      Gemini
    end
  end

  def initialize(user, assistant, conversation, message)
    begin
      @client = self.class.client.new(
        credentials: {
          service: 'generative-language-api',
          api_key: assistant.api_key
        },
        options: { model: assistant.model, server_sent_events: true }
      )
    rescue ::Faraday::UnauthorizedError => e
      raise Faraday::UnauthorizedError
    end
    @assistant = assistant
    @conversation = conversation
    @message = message
  end

  def client_method_name
    :stream_generate_content
  end

  def configuration_error
    ::OpenAI::ConfigurationError
  end

  def set_client_config(config)
    @client_config = {
      contents: config[:messages] #,
      # Systeem instruction is not working well on gem 'gemini-ai'
      #system_instruction: system_message(config[:instructions])
    }
  end

  def get_oneoff_message(instructions, messages, params = {})
    set_client_config(
      messages: preceding_messages,
      #instructions: system_message,
    )

    response = @client.send(client_method_name, @client_config)
    response.dig("candidates",0,"content","parts",0,"text")
  end

  def get_next_chat_message(&chunk_handler)
    set_client_config(
      messages: preceding_messages,
      #instructions: system_message,
    )

    begin
      # Systeem instruction is not working well on gem 'gemini-ai'
      #response = @client.stream_generate_content({contents: preceding_messages,system_instruction: system_message})
      #response = @client.stream_generate_content({contents: preceding_messages})
      response = @client.send(client_method_name, @client_config) do |event, parsed, raw|
        puts "Event from Gemini"
        puts event.inspect
        yield event["candidates"][0]["content"]["parts"][0]["text"] if event["candidates"][0]["content"]["parts"].present?
      end
    rescue ::Faraday::UnauthorizedError => e
      puts e.message
      raise OpenAI::ConfigurationError
    end
    return nil
  end

  private

  def system_message
    return [] if @assistant.instructions.blank?
    {
      role: 'user', parts: { text: @assistant.instructions }
    }
  end

  def preceding_messages
    @conversation.messages.for_conversation_version(@message.version).where("messages.index < ?", @message.index).collect do |message|
      if @assistant.images && message.documents.present?

        content = [{ type: "text", text: message.content_text }]
        content += message.documents.collect do |document|
          { type: "image_url", image_url: { url: document.file_data_url(:large) }}
        end

        {
          role: message.role == "assistant" ? "model" : "user", parts: content
        }
      else
        {
          role: message.role == "assistant" ? "model" : "user", parts: { text: message.content_text || "" }
        }
      end
    end
  end
end

