class ProjectPolicy < ApplicationPolicy
  attr_reader :user, :project

  def initialize(user, project)
    @user = user
    @project = project
  end

  def destroy?
    project.owner?(user)
  end

  def edit?
    project.owner?(user)
  end

  def update?
    project.owner?(user)
  end

  def member?
    project.active_membership?(user)
  end
end
