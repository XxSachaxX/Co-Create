class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects, id: :string do |t|
      t.string :name
      t.string :description
      t.references :user, type: :string, null: false, foreign_key: true

      t.timestamps
    end
  end
end
