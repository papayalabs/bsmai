class Settings::UsersController < Settings::ApplicationController
  before_action :set_user, only: [:edit,:update,:destroy]
  before_action :set_roles, only: [:new,:edit]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to settings_users_path, notice: "Created", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to edit_settings_user_path, notice: "Saved", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!
    redirect_to settings_users_path, notice: "Deleted", status: :see_other
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_roles
    @roles = User.roles.keys {|p| [p.name, p.id]}
  end

  def person_params
    params.require(:person).permit(:email)
  end

  def user_params
    params.require(:user).permit(:id, :email, :first_name,:last_name,:password, :role,:active)
  end
end