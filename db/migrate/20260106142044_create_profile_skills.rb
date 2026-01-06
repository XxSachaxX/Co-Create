class CreateProfileSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_skills, id: :string do |t|
      t.belongs_to :profile, null: false, foreign_key: true, type: :string
      t.belongs_to :skill, null: false, foreign_key: true, type: :string

      t.timestamps
    end

    add_index :profile_skills, [ :profile_id, :skill_id ], unique: true
  end
end
