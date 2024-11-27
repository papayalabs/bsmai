class Settings::GeneralSettingsController < Settings::ApplicationController
  before_action :set_general_setting, only: [:edit, :update]

  def edit
  end

  def update
    if @general_setting.update(general_setting_params)
      redirect_to edit_settings_general_setting_path(@general_setting), notice: "Saved", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_general_setting
    @general_setting = GeneralSetting.first
  end

  def general_setting_params
    params.require(:general_setting).permit(:google_api_key,:theme_preference)
  end
end