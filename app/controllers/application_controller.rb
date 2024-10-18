class ApplicationController < ActionController::Base
 # include Authenticate
  before_action :set_current_user
  helper_method [:current_user]

  def current_user
    @current_user = User.last
  end

  def set_current_user
    Current.user = User.last
    if PromptProcess.first == nil
      PromptProcess.create!(:name => "New Process")
    end
  end

end
