class RestrictedToOwnerError < ApplicationError
  def initialize(message = I18n.t("project_membership_requests.controller.errors.restricted_to_owner"))
    super(message)
  end
end
