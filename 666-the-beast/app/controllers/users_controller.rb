class UsersController < Controller
  def index
    @users = User.all
  end

  def show
    @user = User.find params[:id]
  end

  private
  def user_path(user)
    "/users/#{user.id}"
  end
end
