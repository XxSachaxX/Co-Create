class ProjectMembershipRequestsController < ApplicationController
  class RestrictedToOwnerError < StandardError
    def initialize(message = I18n.t("project_membership_requests.controller.errors.restricted_to_owner"))
      super(message)
    end
  end

  def create
    project = Project.find(params[:project_id])

    if ProjectMembershipRequest.exists?(user: Current.user, project: project, status: ProjectMembershipRequest::PENDING)
      flash[:error] = I18n.t("project_membership_requests.controller.already_requested")
      redirect_to project_path(project)
      return
    end

    if ProjectMembership.exists?(user: Current.user, project: project)
      flash[:error] = I18n.t("project_membership_requests.controller.already_a_member")
      redirect_to project_path(project)
      return
    end

    project_membership_request = project.project_membership_requests.new(
      user: Current.user,
      description: membership_request_params[:description]
    )

    if project_membership_request.save!
      flash[:notice] = I18n.t("project_membership_requests.controller.request_sent")
    else
      flash[:error] = I18n.t("project_membership_requests.controller.errors.request_failed")
    end

    redirect_to project_path(project)
  end

  def new
    @user = Current.user
    @project = Project.find(params[:project_id])
    @project_membership_request = @project.project_membership_requests.new(user: @user)
  end

  def accept
    membership = ProjectMembershipRequest.find(params[:id])
    project = membership.project

    raise RestrictedToOwnerError unless project.owner?(Current.user)

    membership.accept!
    project.create_membership!(membership.user)

    redirect_to project_path(project)
    flash[:notice] = I18n.t("project_membership_requests.controller.accepted", username: membership.user.name, project_name: project.name)
  end

  def reject
    membership = ProjectMembershipRequest.find(params[:id])
    project = membership.project

    raise RestrictedToOwnerError unless project.owner?(Current.user)
    membership.reject!

    redirect_to project_path(project)
    flash[:notice] = I18n.t("project_membership_requests.controller.rejected")
  end


  private

  def membership_request_params
    params.require(:project_membership_request).permit(:description)
  end
end
