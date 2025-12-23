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
      redirect_to project_path(project), notice: I18n.t("projects.controller.creation_successful")
    else
      render :new
    end
  end

  def destroy
    authorize current_project
    current_project.destroy!
    redirect_to projects_path, notice: I18n.t("projects.controller.deletion_successful")
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
      redirect_to project_path(current_project), notice: I18n.t("projects.controller.update_successful")
    else
      render :edit
    end
  end

  def user_projects
    @user = User.find(params[:user_id])
    authorize @user, :user_projects?
    @projects = @user.projects.includes(:project_membership_requests)
    render :user_projects
  end

  def leave
    return unless current_project.collaborator?(current_user)

    current_project.project_memberships.find_by(user: current_user).destroy!
    redirect_to project_path(current_project), notice: I18n.t("projects.controller.successfully_left")
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
