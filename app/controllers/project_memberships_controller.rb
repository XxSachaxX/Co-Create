class ProjectMembershipsController < ApplicationController
  class RestrictedToOwnerError < StandardError
    def initialize(message = I18n.t("project_membership_requests.controller.errors.restricted_to_owner"))
      super(message)
    end
  end

  def revoke
    membership = ProjectMembership.find(params[:id])
    raise RestrictedToOwnerError unless membership.project.owner?(Current.user)

    membership.update(status: "revoked")
    redirect_to project_path(membership.project), notice: "Membership revoked"
  end

  private
end
