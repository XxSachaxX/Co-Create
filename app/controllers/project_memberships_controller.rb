class ProjectMembershipsController < ApplicationController
  def revoke
    membership = ProjectMembership.find(params[:id])
    membership.update(status: "revoked")
    redirect_to project_path(membership.project), notice: "Membership revoked"
  end
end
