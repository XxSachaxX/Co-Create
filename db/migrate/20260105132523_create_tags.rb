class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags, id: :string do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :projects_count, default: 0, null: false
      t.timestamps
    end
  end
end
