class CreateSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :skills, id: :string do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :skills, :name, unique: true
  end
end
