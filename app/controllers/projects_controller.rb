class ProjectsController < ApplicationController

  def index
    @projects = Project.all
    @user = current_user
    render :index
  end

  def new
    @user = current_user
    @project = Project.new
  end

  def create
    if current_user.projects.create!(project_params)
      redirect_to root_path, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def show
    @project = Project.find(params[:id])
    @user = current_user
    render :show
  end

  def user_projects
    @user = User.find(params[:user_id])
    authorize @user, :user_projects?
    @projects = @user.projects
    render :user_projects
  end

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:current_user_id]) if session[:current_user_id]
  end
end
