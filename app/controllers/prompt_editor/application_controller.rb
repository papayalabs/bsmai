class PromptEditor::ApplicationController < ApplicationController
  layout "prompt_editor"
  before_action :set_prompt_editor_menu, :admin_authorization

  private

  def set_prompt_editor_menu
    # controller_name => array of items
    @settings_menu = {
      new_prompt_process: {
        #'Account': edit_settings_person_path,
        'Create New Process': new_prompt_editor_prompt_process_path
      },

      prompt_processes: PromptProcess.all.map {
        |prompt_process| [ prompt_process, edit_prompt_editor_prompt_process_path(prompt_process) ]
      }.to_h,
    }
  end

  def admin_authorization
    if Current.user.role != "admin"
      redirect_to root_path, notice: "Your are not authorized", status: :see_other
    end
  end
end