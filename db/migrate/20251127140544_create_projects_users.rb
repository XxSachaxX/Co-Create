class CreateProjectsUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :projects_users, id: false do |t|
      t.belongs_to :user, type: :string
      t.belongs_to :project, type: :string
      t.timestamps
    end
  end
end
