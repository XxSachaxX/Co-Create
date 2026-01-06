class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles, id: :string do |t|
      t.text :description
      t.belongs_to :user, null: false, foreign_key: true, type: :string

      t.timestamps
    end
  end
end
