class ApplicationController < ActionController::Base
 # include Authenticate
  protect_from_forgery with: :null_session
  before_action :set_current_user
  helper_method [:current_user]

  def current_user
    @current_user = User.last
  end

  def set_current_user
    Current.user = User.last
    if PromptProcess.all.count == 0
      PromptProcess.create!(:name => "New Process")
    end
  end

end
