class CreateProjectMembershipRequest < ActiveRecord::Migration[8.1]
  def change
    create_table :project_membership_requests, id: :string do |t|
      t.timestamps
      t.belongs_to :project, null: false, foreign_key: true, type: :string
      t.belongs_to :user, null: false, foreign_key: true, type: :string
      t.string :status, null: false, default: "pending"
    end
  end
end
