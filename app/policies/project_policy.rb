class ProjectPolicy < ApplicationPolicy
  attr_reader :user, :project

  def initialize(user, project)
    @user = user
    @project = project
  end

  def destroy?
    membership = project.project_memberships.find_by(user: user)
    membership&.role == 'owner'
  end
end
