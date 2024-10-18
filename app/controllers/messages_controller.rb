class MessagesController < ApplicationController
  include ActiveStorage::SetCurrent
  include HasConversationStarter

  before_action :set_version,               only: [:index, :update]
  before_action :set_conversation,          only: [:index]
  before_action :set_assistant,             only: [:index, :new, :edit, :create]
  before_action :set_message,               only: [:show, :edit, :update]
  before_action :set_nav_conversations,     only: [:index, :new, :send_google_sheet_url]
  before_action :set_nav_assistants,        only: [:index, :new, :send_google_sheet_url]
  before_action :set_conversation_starters, only: [:new, :send_google_sheet_url]

  def index
    if @version.blank?
      version = @conversation.messages.order(:created_at).last&.version
      redirect_to conversation_messages_path(
        params[:conversation_id],
        version: version
      ) if version
    end

    @messages = @conversation.messages.for_conversation_version(@version)
    @new_message = @assistant.messages.new(conversation: @conversation)
    @streaming_message = Message.where(
      content_text: [nil, ""],
      cancelled_at: nil
    ).find_by(id: @conversation.last_assistant_message_id)
  end

  def show
  end

  def new
    @new_message = @assistant.messages.new
  end

  def edit
    @new_message = @assistant.messages.new
  end

  def create
    if params[:prompt_index].present?
      current_prompt = Prompt.find(params[:prompt_index])
      prompt_process = current_prompt.prompt_process
      prompts = prompt_process.prompts.priority
      index = 0
      prompts.each do |prompt|
        if prompt == current_prompt
          break
        else
          index += 1
        end
      end
      index += 1
      next_prompt = prompt_process.prompts.priority[index]
      conversation = Conversation.find(params[:message][:conversation_id])
      params[:message][:content_text] = get_prompt_instructions_with_google_sheet(next_prompt.id,conversation.state["google_sheet_id"])
    end

    @message = @assistant.messages.new(message_params)

    if @message.save
      if params[:prompt_index].present?
        @message.conversation.state["prompt_index"] = next_prompt.id
        @message.conversation.save
      end
      after_create_assistant_reply = @message.conversation.latest_message_for_version(@message.version)
      GetNextAIMessageJob.perform_later(current_user.id, after_create_assistant_reply.id, @assistant.id)
      redirect_to conversation_messages_path(@message.conversation, version: @message.version)
    else
      # what's the right flow for a failed message create? it's not this, but hacking it so tests pass until we have a plan
      set_nav_conversations
      set_nav_assistants
      @new_message = @assistant.messages.new

      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Clicking edit beneath a message actually submits to create and not here. This action is only used for next/prev conversation.
    # In order to force a morph we PATCH to here and redirect.
    if @message.update(message_params)
      redirect_to conversation_messages_path(@message.conversation, version: @version || @message.version)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def send_google_sheet_url
    unless params[:prompt_process_id].present?
      redirect_to assistants_path, error: "You need to select a Prompt Process"
    end
    prompt_process = PromptProcess.find(params[:prompt_process_id])
    google_sheet_id = params[:url].split("docs.google.com/spreadsheets/d/")[1].split("/")[0].to_s
    prompt_index = prompt_process.prompts.priority.first.id
    prompt_instructions = get_prompt_instructions_with_google_sheet(prompt_index,google_sheet_id)

    @assistant = Current.user.assistants.find_by(id: params[:assistant_id])
    @conversation = Current.user.conversations.new(assistant_id: @assistant.id)
    @assistant ||= @conversation.latest_message_for_version(@version).assistant

    @message = @assistant.messages.new(content_text: prompt_instructions)

    if @message.save
      @message.conversation.state["prompt_index"] = prompt_index
      @message.conversation.state["google_sheet_id"] = google_sheet_id
      @message.conversation.save
      after_create_assistant_reply = @message.conversation.latest_message_for_version(@message.version)
      GetNextAIMessageJob.perform_later(current_user.id, after_create_assistant_reply.id, @assistant.id)
      redirect_to conversation_messages_path(@message.conversation, version: @message.version)
    else
      # what's the right flow for a failed message create? it's not this, but hacking it so tests pass until we have a plan
      set_nav_conversations
      set_nav_assistants
      @new_message = @assistant.messages.new

      render :new, status: :unprocessable_entity
    end
  end

  def get_prompt_instructions_with_google_sheet(prompt_index,google_sheet_id)
    url = 'https://docs.google.com/spreadsheets/d/'+google_sheet_id+'/export?format=xlsx'
    xls = Roo::Spreadsheet.open(url, extension: :xlsx)

    prompt = Prompt.find(prompt_index)
    prompt_instructions = prompt.instructions

    tags = prompt_instructions.scan(/\[(\w+)\,(\d+)\]/)
    tags.each do |tag|
      prompt_instructions.gsub!("["+tag[0]+","+tag[1]+"]",xls.sheet(0).cell(tag[0],tag[1].to_i).to_s)
    end
    prompt_instructions
  end



  private

  def set_version
    @version = params[:version].presence&.to_i
  end

  def set_conversation
    @conversation = Current.user.conversations.find(params[:conversation_id])
  end

  def set_assistant
    @assistant = Current.user.assistants.find_by(id: params[:assistant_id])
    @assistant ||= @conversation.latest_message_for_version(@version).assistant
  end

  def set_message
    @message = Message.find(params[:id])
  end

  def set_nav_conversations
    @nav_conversations = Conversation.grouped_by_increasing_time_interval_for_user(Current.user)
  end

  def set_nav_assistants
    @nav_assistants = Current.user.assistants.ordered
  end

  def message_params
    modified_params = params.require(:message).permit(
      :conversation_id,
      :content_text,
      :assistant_id,
      :index,
      :version,
      :role,
      :cancelled_at,
      :branched,
      :branched_from_version,
      documents_attributes: [:file]
    )
    if modified_params.has_key?(:content_text) && modified_params[:content_text].blank?
      modified_params[:content_text] = nil # nil and "" have different meanings
    end
    modified_params
  end
end
