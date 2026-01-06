class CreateProfileInterests < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_interests, id: :string do |t|
      t.belongs_to :profile, null: false, foreign_key: true, type: :string
      t.belongs_to :interest, null: false, foreign_key: true, type: :string

      t.timestamps
    end

    add_index :profile_interests, [ :profile_id, :interest_id ], unique: true
  end
end
