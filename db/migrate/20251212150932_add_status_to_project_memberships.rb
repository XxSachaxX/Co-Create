class AddStatusToProjectMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :project_memberships, :status, :string, default: 'pending'
  end
end
