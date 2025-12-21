class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]

  def new
    render :new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, notice: "User was successfully created."
    else
      render :new
    end
  end

  def user_params
    params.require(:user).permit(:email_address, :password, :name)
  end
end
