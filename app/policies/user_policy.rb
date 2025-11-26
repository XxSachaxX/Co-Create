class UserPolicy < ApplicationPolicy
  def user_projects?
    user.id == record.id
  end
end
