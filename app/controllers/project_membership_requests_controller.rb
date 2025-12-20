class ProjectMembershipRequestsController < ApplicationController
  def create
    project = Project.find(params[:project_id])

    if ProjectMembershipRequest.exists?(user: current_user, project: project)
      flash[:error] = "You already requested membership for this project."
      redirect_to project_path(project)
      return
    end

    if ProjectMembership.exists?(user: current_user, project: project)
      flash[:error] = "You are already a member of this project."
      redirect_to project_path(project)
      return
    end

    project_membership_request = project.project_membership_requests.new(user: current_user)

    if project_membership_request.save!
      flash[:notice] = "Membership request sent!"
    else
      flash[:error] = "Failed to send membership request."
    end

    redirect_to project_path(project)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:current_user_id]) if session[:current_user_id]
  end
end
