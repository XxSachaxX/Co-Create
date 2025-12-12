class DropProjectsUsers < ActiveRecord::Migration[8.1]
  def change
    drop_table :projects_users
  end
end
