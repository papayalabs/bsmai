class Settings::ApplicationController < ApplicationController
  layout "settings"
  before_action :set_settings_menu, :admin_authorization

  private

  def set_settings_menu
    # controller_name => array of items
    @settings_menu = {
      assistants: Assistant.ordered.map {
        |assistant| [ assistant, edit_settings_assistant_path(assistant) ]
      }.to_h.merge({
        #'New Assistant': new_settings_assistant_path(Assistant.new)
      }),

      users: {
        'Users': settings_users_path
      }
    }
  end

  def admin_authorization
    if Current.user.role != "admin"
      redirect_to root_path, notice: "Your are not authorized", status: :see_other
    end
  end
end
