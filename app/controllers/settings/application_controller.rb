class Settings::ApplicationController < ApplicationController
  layout "settings"
  before_action :set_settings_menu

  private

  def set_settings_menu
    # controller_name => array of items
    @settings_menu = {
      assistants: Assistant.ordered.map {
        |assistant| [ assistant, edit_settings_assistant_path(assistant) ]
      }.to_h.merge({
        #'New Assistant': new_settings_assistant_path(assistant)
      }),
    }
  end
end
