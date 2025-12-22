class AddDescriptionToProjectMembershipRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :project_membership_requests, :description, :string
  end
end
