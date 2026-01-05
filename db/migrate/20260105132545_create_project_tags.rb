class CreateProjectTags < ActiveRecord::Migration[8.1]
  def change
    create_table :project_tags, id: :string do |t|
      t.references :tag, type: :string, null: false, foreign_key: true
      t.references :project, type: :string, null: false, foreign_key: true
      t.timestamps
    end

    add_index :project_tags, [ :tag_id, :project_id ], unique: true
    add_index :project_tags, [ :project_id, :tag_id ]
  end
end
