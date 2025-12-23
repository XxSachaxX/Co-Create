class ProjectMembershipRequestsController < ApplicationController
  class RestrictedToOwnerError < StandardError
    def initialize(message = I18n.t("project_membership_requests.errors.restricted_to_owner"))
      super(message)
    end
  end

  def create
    project = Project.find(params[:project_id])

    if ProjectMembershipRequest.exists?(user: current_user, project: project, status: ProjectMembershipRequest::PENDING)
      flash[:error] = I18n.t("project_membership_requests.already_requested")
      redirect_to project_path(project)
      return
    end

    if ProjectMembership.exists?(user: current_user, project: project)
      flash[:error] = I18n.t("project_membership_requests.already_a_member")
      redirect_to project_path(project)
      return
    end

    project_membership_request = project.project_membership_requests.new(
      user: current_user,
      description: membership_request_params[:description]
    )

    if project_membership_request.save!
      flash[:notice] = I18n.t("project_membership_requests.request_sent")
    else
      flash[:error] = I18n.t("project_membership_requests.errors.request_failed")
    end

    redirect_to project_path(project)
  end

  def new
    @user = current_user
    @project = Project.find(params[:project_id])
    @project_membership_request = @project.project_membership_requests.new(user: @user)
  end

  def accept
    membership = ProjectMembershipRequest.find(params[:id])
    project = membership.project

    raise RestrictedToOwnerError unless project.owner?(current_user)

    membership.accept!
    project.create_membership!(membership.user)

    redirect_to project_path(project)
    flash[:notice] = I18n.t("project_membership_requests.accepted", username: membership.user.name, project_name: project.name)
  end

  def reject
    membership = ProjectMembershipRequest.find(params[:id])
    project = membership.project

    raise RestrictedToOwnerError unless project.owner?(current_user)
    membership.reject!

    redirect_to project_path(project)
    flash[:notice] = I18n.t("project_membership_requests.rejected")
  end


  private

  def current_user
    @current_user ||= User.find_by(id: session[:current_user_id]) if session[:current_user_id]
  end

  def membership_request_params
    params.require(:project_membership_request).permit(:description)
  end
end
