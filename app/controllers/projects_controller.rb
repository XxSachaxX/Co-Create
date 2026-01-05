class ProjectsController < ApplicationController
  def index
    @projects = Project.includes(:tags).order(created_at: :desc)

    # Filter by tags
    tag_names = Array(params[:tags]).compact_blank
    @projects = @projects.with_any_tags(tag_names) if tag_names.any?

    # For filter dropdown
    @available_tags = Tag.popular.limit(50)
    @selected_tags = tag_names

    @user = Current.user
    render :index
  end

  def new
    @user = Current.user
    @project = Project.new
  end

  def create
    @user = Current.user
    @project = @user.projects.new(**project_params, project_memberships_attributes: [ role: ProjectMembership::OWNER, user: @user, status: ProjectMembership::ACTIVE ])
    if @project.save!
      redirect_to project_path(@project), notice: I18n.t("projects.controller.creation_successful")
    else
      render :new
    end
  end

  def destroy
    @project = current_project
    authorize @project
    @project.destroy!
    redirect_to projects_path, notice: I18n.t("projects.controller.deletion_successful")
  end

  def show
    @project = current_project
    @user = Current.user
    render :show
  end

  def edit
    @user = Current.user
    @project = current_project
    authorize @project
    render :edit
  end

  def update
    @user = Current.user
    @project = current_project
    authorize @project
    if @project.update(project_params)
      redirect_to project_path(@project), notice: I18n.t("projects.controller.update_successful")
    else
      render :edit
    end
  end

  def user_projects
    @user = User.find(params[:user_id])
    authorize @user, :user_projects?
    @projects = @user.projects.includes(:project_membership_requests).where(project_memberships: { status: ProjectMembership::ACTIVE })
    render :user_projects
  end

  def leave
    @project = current_project
    @user = Current.user
    return unless @project.collaborator?(@user)

    @project.project_memberships.find_by(user: @user).destroy!
    redirect_to project_path(@project), notice: I18n.t("projects.controller.successfully_left")
  end

  private

  def project_params
    params.require(:project).permit(:name, :description, :tag_names)
  end

  def current_project
    @current_project ||= Project.find(params[:id]) if params[:id]
  end
end
