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

  def get_oneoff_message(instructions, messages, params = {})
    begin
      response = @client.generate_content(
        { contents: preceding_messages }
      )
      response_text = response["candidates"][0]["content"]["parts"][0]["text"]
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
      # Systeem instruction is not working well on gem 'gemini-ai'
      #response = @client.stream_generate_content({contents: preceding_messages,system_instruction: system_message})
      response = @client.stream_generate_content({contents: preceding_messages})
    rescue ::Faraday::UnauthorizedError => e
      puts e.message
      raise Faraday::UnauthorizedError
    end
    return response.map { |h| h["candidates"][0]["content"]["parts"][0]["text"] }
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

