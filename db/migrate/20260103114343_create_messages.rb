class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages, id: :string do |t|
      t.belongs_to :user
      t.belongs_to :project
      t.string :content, null: false
      t.timestamps
    end
  end
end
