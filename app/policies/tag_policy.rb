class TagPolicy < ApplicationPolicy
  def index?
    true  # Tags are public, anyone can view them
  end
end
