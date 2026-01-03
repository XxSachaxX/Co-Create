class FixMessagesReferences < ActiveRecord::Migration[8.1]
  def change
    remove_column :messages, :user_id
    remove_column :messages, :project_id

    add_column :messages, :user_id, :string
    add_column :messages, :project_id, :string

    add_index :messages, :user_id
    add_index :messages, :project_id
  end
end
