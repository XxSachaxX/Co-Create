class CreateProjectMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :project_memberships, id: :string do |t|
      t.belongs_to :project, type: :string
      t.belongs_to :user, type: :string
      t.string :role, null: false, default: 'member'
      t.timestamps
    end
  end
end
