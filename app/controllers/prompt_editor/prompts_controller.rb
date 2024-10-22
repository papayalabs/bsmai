class PromptEditor::PromptsController < PromptEditor::ApplicationController
  before_action :set_prompt, only: [:show, :edit, :update, :destroy]

  def index
    @prompt_process = PromptProcess.find(params[:prompt_process_id])
    @prompts = Prompt.where(prompt_process_id: @prompt_process.id).order(priority: :asc).order(updated_at: :desc)
  end

  def edit
  end

  def show
  end

  def new
    @prompt = Prompt.new
  end

  def create
    @prompt = Prompt.new(prompt_params)
    @prompt.prompt_process_id = params[:prompt_process_id]
    @prompt.priority = PromptProcess.find(params[:prompt_process_id]).prompts.length+1

    if @prompt.save
      redirect_to prompt_editor_prompts_path(prompt_process_id: @prompt.prompt_process.id), notice: "Saved", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @prompt.update(prompt_params)
      redirect_to prompt_editor_prompts_path(prompt_process_id: @prompt.prompt_process.id), notice: "Saved", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @prompt.destroy!
    redirect_to prompt_editor_prompts_path(prompt_process_id: @prompt.prompt_process.id), notice: "Deleted", status: :see_other
  end

  private

  def set_prompt
    @prompt = Prompt.find_by(id: params[:id])
    if @prompt.nil?
      redirect_to prompt_editor_prompts_path(prompt_process_id: @prompt.prompt_process.id), status: :see_other, alert: "The Prompt could not be found"
    end
  end

  def prompt_params
    params.require(:prompt).permit(:name, :description, :instructions, :priority)
  end
end
