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
    project = current_user.projects.new(**project_params, project_memberships_attributes: [ role: ProjectMembership::OWNER, user: current_user, status: ProjectMembership::ACTIVE ])
    if project.save!
      redirect_to project_path(project), notice: "Project was successfully created."
    else
      render :new
    end
  end

  def destroy
    authorize current_project
    current_project.destroy!
    redirect_to projects_path, notice: "Project was successfully deleted."
  end

  def show
    @project = current_project
    @user = current_user
    render :show
  end

  def edit
    @user = current_user
    authorize current_project
    render :edit
  end

  def update
    authorize current_project
    if current_project.update(project_params)
      redirect_to project_path(current_project), notice: "Project was successfully updated."
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

  def join
    current_project.project_memberships.create!(user: current_user, role: ProjectMembership::MEMBER, status: ProjectMembership::PENDING)
    redirect_to project_path(current_project), notice: "Your request to join the project has been sent."
  end

  def leave
    return unless current_project.collaborator?(current_user)

    current_project.project_memberships.find_by(user: current_user).destroy!
    redirect_to project_path(current_project), notice: "You have left the project."
  end

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end

  def current_project
    @current_project ||= Project.find(params[:id]) if params[:id]
  end

  def current_user
    @current_user ||= User.find_by(id: session[:current_user_id]) if session[:current_user_id]
  end
end
