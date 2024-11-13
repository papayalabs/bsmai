class SessionsController < ApplicationController
  include Accessible

  layout "public"

  def new
  end

  def create
    user = User.find_by(email: params[:email].strip.downcase)

    if user.blank?
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
      return
    end

    if user.active == false
      flash.now[:alert] = "Your User need Activation from Admin"
      render :new, status: :unprocessable_entity
      return
    end

    @user = user

    if @user&.authenticate(params[:password])
      reset_session
      login_as @user
      redirect_to root_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    Current.user = nil
    redirect_to login_path
  end
end
