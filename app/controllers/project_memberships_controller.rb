class ProjectMembershipsController < ApplicationController
  def revoke
    membership = ProjectMembership.find(params[:id])
    raise RestrictedToOwnerError unless membership.project.owner?(Current.user)

    membership.update(status: "revoked")
    redirect_to project_path(membership.project), notice: "Membership revoked"
  end

  private
end
