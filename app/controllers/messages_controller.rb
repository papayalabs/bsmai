class MessagesController < ApplicationController
  include ActiveStorage::SetCurrent
  include HasConversationStarter

  before_action :set_version,               only: [:index, :update]
  before_action :set_conversation,          only: [:index]
  before_action :set_assistant,             only: [:index, :new, :edit, :create]
  before_action :set_message,               only: [:show, :edit, :update]
  before_action :set_nav_conversations,     only: [:index, :new, :start_new_process]
  before_action :set_nav_assistants,        only: [:index, :new, :start_new_process]
  before_action :set_conversation_starters, only: [:new, :start_new_process]

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
    puts "Create a new Message"
    puts message_params.inspect
    if params[:prompt_index].present?
      last_prompt = false
      current_prompt = Prompt.find(params[:prompt_index])
      prompt_process = current_prompt.prompt_process
      prompts = prompt_process.prompts
      index = 0
      prompts.each do |prompt|
        if prompt == current_prompt
          break
        else
          index += 1
        end
      end
      index += 1
      next_prompt = prompt_process.prompts[index]
      if next_prompt == prompt_process.prompts.last
        last_prompt = true
      end
      conversation = Conversation.find(params[:message][:conversation_id])
      next_prompt_instructions = next_prompt.instructions
      next_prompt_instructions = get_prompt_instructions_with_google_sheet_1(next_prompt_instructions,conversation.state["google_sheet_1_id"]) if conversation.state["google_sheet_1_id"].present?
      next_prompt_instructions = get_prompt_instructions_with_google_sheet_2(next_prompt_instructions,conversation.state["google_sheet_2_id"]) if conversation.state["google_sheet_2_id"].present?
      next_prompt_instructions = get_prompt_instructions_with_google_doc(next_prompt_instructions,conversation.state["google_doc_1_id"],1) if conversation.state["google_doc_1_id"].present?
      next_prompt_instructions = get_prompt_instructions_with_google_doc(next_prompt_instructions,conversation.state["google_doc_2_id"],2) if conversation.state["google_doc_2_id"].present?
      params[:message][:content_text] = next_prompt_instructions
    end

    @message = @assistant.messages.new(message_params)

    if @message.save
      unless params[:message][:content_text].include?("Prompt Instructions Runtime Error:")
        puts "Message were created"
        if params[:prompt_index].present?
          @message.conversation.state["prompt_index"] = next_prompt.id
          @message.conversation.state["last_prompt"] = last_prompt
          @message.conversation.save
          puts "Conversation were created/updated: "+@message.conversation.inspect
        end
        after_create_assistant_reply = @message.conversation.latest_message_for_version(@message.version)
        GetNextAIMessageJob.perform_later(Current.user.id, after_create_assistant_reply.id, @assistant.id)
      end
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

  def start_new_process
    unless params[:prompt_process_id].present?
      redirect_to assistants_path, error: "You need to select a Prompt Process"
    end
    last_prompt = false
    prompt_process = PromptProcess.find(params[:prompt_process_id])
    prompt_index = prompt_process.prompts.first.id
    if prompt_process.prompts.first == prompt_process.prompts.last
      last_prompt = true
    end
    prompt = Prompt.find(prompt_index)
    prompt_instructions = prompt.instructions
    google_sheet_1_id,google_sheet_2_id,google_doc_1_id,google_doc_2_id = nil,nil,nil,nil
    if params[:google_sheet_1_url].present?
      google_sheet_1_id = params[:google_sheet_1_url].split("docs.google.com/spreadsheets/d/")[1].split("/")[0].to_s
      prompt_instructions = get_prompt_instructions_with_google_sheet_1(prompt_instructions,google_sheet_1_id)
    end
    if params[:google_sheet_2_url].present?
      google_sheet_2_id = params[:google_sheet_2_url].split("docs.google.com/spreadsheets/d/")[1].split("/")[0].to_s
      prompt_instructions = get_prompt_instructions_with_google_sheet_2(prompt_instructions,google_sheet_2_id)
    end
    if params[:google_doc_1_url].present?
      google_doc_1_id = params[:google_doc_1_url].split("docs.google.com/document/d/")[1].split("/")[0].to_s
      prompt_instructions = get_prompt_instructions_with_google_doc(prompt_instructions,google_doc_1_id,1)
    end
    if params[:google_doc_2_url].present?
      google_doc_2_id = params[:google_doc_2_url].split("docs.google.com/document/d/")[1].split("/")[0].to_s
      prompt_instructions = get_prompt_instructions_with_google_doc(prompt_instructions,google_doc_2_id,2)
    end
    @assistant = Current.user.assistants.find_by(id: params[:assistant_id])
    @conversation = Current.user.conversations.new(assistant_id: @assistant.id)
    @assistant ||= @conversation.latest_message_for_version(@version).assistant

    @message = @assistant.messages.new
    @message.index = ""
    @message.version = ""
    @message.conversation_id = ""
    @message.content_text = prompt_instructions

    puts "We are starting a New Process with the Prompt: "+prompt_instructions.to_s

    if @message.save
      puts "Message were saved"
      unless prompt_instructions.include? "Prompt Instructions Runtime Error:"
        @message.conversation.state["prompt_index"] = prompt_index
        @message.conversation.state["last_prompt"] = last_prompt
        @message.conversation.state["google_sheet_1_id"] = google_sheet_1_id if google_sheet_1_id != nil
        @message.conversation.state["google_sheet_2_id"] = google_sheet_2_id if google_sheet_2_id != nil
        @message.conversation.state["google_doc_1_id"] = google_doc_1_id if google_doc_1_id != nil
        @message.conversation.state["google_doc_2_id"] = google_doc_2_id if google_doc_2_id != nil
        @message.conversation.save
        puts "Conversation were updated: "+@message.conversation.inspect
        after_create_assistant_reply = @message.conversation.latest_message_for_version(@message.version)
        GetNextAIMessageJob.perform_later(Current.user.id, after_create_assistant_reply.id, @assistant.id) 
      end
      redirect_to conversation_messages_path(@message.conversation, version: @message.version)
    else
      # what's the right flow for a failed message create? it's not this, but hacking it so tests pass until we have a plan
      set_nav_conversations
      set_nav_assistants
      @new_message = @assistant.messages.new

      render :new, status: :unprocessable_entity
    end
  end

  def get_prompt_instructions_with_google_sheet_1(prompt_instructions,google_sheet_1_id)
    url = 'https://docs.google.com/spreadsheets/d/'+google_sheet_1_id+'/export?format=xlsx'
    begin
      xls = Roo::Spreadsheet.open(url, extension: :xlsx)
    rescue StandardError => e
      return "Prompt Instructions Runtime Error: "+e.message.to_s
    end

    puts prompt_instructions.inspect
    tags = prompt_instructions.scan(/\[SHEET1,(\w+)\,(\d+)\]/)
    puts tags.inspect
    tags.each do |tag|
      cell_content = xls.sheet(0).cell(tag[0],tag[1].to_i)
      if cell_content.present?
        prompt_instructions.gsub!("[SHEET1,"+tag[0]+","+tag[1]+"]",cell_content)
      else
        return "Prompt Instructions Runtime Error: Unable to run next prompt, [SHEET1,"+tag[0]+","+tag[1]+"]  is missing content. Please update before continuing"
      end
    end
    prompt_instructions
  end

  def get_prompt_instructions_with_google_sheet_2(prompt_instructions,google_sheet_2_id)
    url = 'https://docs.google.com/spreadsheets/d/'+google_sheet_2_id+'/export?format=xlsx'
    begin
      xls = Roo::Spreadsheet.open(url, extension: :xlsx)
    rescue StandardError => e
      return "Prompt Instructions Runtime Error: "+e.message.to_s
    end

    tags = prompt_instructions.scan(/\[SHEET2,(\w+)\,(\d+)\]/)
    tags.each do |tag|
      cell_content = xls.sheet(0).cell(tag[0],tag[1].to_i)
      if cell_content.present?
        prompt_instructions.gsub!("[SHEET2,"+tag[0]+","+tag[1]+"]",cell_content)
      else
        return "Prompt Instructions Runtime Error: Unable to run next prompt, [SHEET2,"+tag[0]+","+tag[1]+"]  is missing content. Please update before continuing"
      end
    end
    prompt_instructions
  end

  def get_prompt_instructions_with_google_doc(prompt_instructions,google_doc_id,doc_number)
    drive = Google::Apis::DriveV3::DriveService.new
    drive.key = "AIzaSyA3_3KUVPruooI3M0lpzoG-yBKcm3i0jJQ"
    txt = drive.export_file(google_doc_id,"text/plain")
    prompt_instructions.gsub!("[DOC"+doc_number.to_s+"]",txt)
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
