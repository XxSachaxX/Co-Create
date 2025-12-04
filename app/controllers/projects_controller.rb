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
    project = current_user.projects.new(**project_params, project_memberships_attributes: [ role: "owner", user: current_user])
    if project.save!
      redirect_to project_path(project), notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def destroy
    project = Project.find(params[:id])
    authorize project
    project.destroy!
    redirect_to projects_path, notice: 'Project was successfully deleted.'
  end

  def show
    @project = Project.find(params[:id])
    @user = current_user
    render :show
  end

  def edit
    @user = current_user
    @project = Project.find(params[:id])
    authorize @project
    render :edit
  end

  def update
    @project = Project.find(params[:id])
    authorize @project
    if @project.update(project_params)
      redirect_to project_path(@project), notice: 'Project was successfully updated.'
    else
      render :edit
    end
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
