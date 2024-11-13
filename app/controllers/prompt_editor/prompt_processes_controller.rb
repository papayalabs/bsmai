class PromptEditor::PromptProcessesController < PromptEditor::ApplicationController
  before_action :set_prompt_process, only: [:show, :edit, :update, :destroy,:duplicate]

  def index
    @prompt_processes = PromptProcess.where("id > 0").order(updated_at: :desc)
  end

  def edit
  end

  def show
  end

  def new
    if params[:process_name].present?
      @prompt_process = PromptProcess.new
      @prompt_process.name = params[:process_name]
      if @prompt_process.save
        redirect_to prompt_editor_prompts_path(:prompt_process_id => @prompt_process.id), notice: "Created", status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update
    if @prompt_process.update(prompt_process_params)
      redirect_to prompt_editor_prompt_process_path, notice: "Saved", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @prompt_process.destroy!
    redirect_to  prompt_editor_prompts_path(:prompt_process_id => PromptProcess.first), notice: "Deleted", status: :see_other
  end

  def duplicate
    prompt_process = @prompt_process.dup
    if prompt_process.save
      @prompt_process.prompts.each do |prompt|
        prompt_dup = prompt.dup
        prompt_dup.prompt_process_id = prompt_process.id
        unless prompt_dup.save
          redirect_to prompt_editor_prompts_path, status: :see_other, alert: "Error duplicated prompts"
        end
      end 
      redirect_to prompt_editor_prompts_path, status: :see_other, alert: "The Prompt Process has been duplicated"
    end
  end

  private

  def set_prompt_process
    @prompt_process = PromptProcess.find_by(id: params[:id])
    if @prompt_process.nil?
      redirect_to prompt_editor_prompts_path, status: :see_other, alert: "The Prompt Process could not be found"
    end
  end

  def prompt_process_params
    params.require(:prompt_process).permit(:name)
  end
end