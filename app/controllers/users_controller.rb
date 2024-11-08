class UsersController < ApplicationController
  include Accessible

  layout "public"

  before_action :ensure_registration, only: [:new, :create]
  before_action :set_user, only: [:update]

  def new
    @user = User.new
  end

  def create
    if params[:user][:name].present?
      params[:user][:first_name] = params[:user][:name].split(" ")[0]
      params[:user][:last_name] = params[:user][:name].split(" ")[1]
    end

    @user = User.new(user_params)
    @user.role = :user
    @user.active = false

    if @user.save
      reset_session
      login_as @user

      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      Current.user.reload
      redirect_back fallback_location: root_path, status: :see_other
    else
      redirect_back fallback_location: root_path, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user if params[:id].to_i == Current.user.id
  end

  def user_params
    params.require(:user).permit(:id, :email, :first_name,:last_name,:password, :role,:active, preferences: [:nav_closed, :dark_mode])
  end

  def ensure_registration
    redirect_to root_path unless Feature.enabled?(:registration)
  end
end
