# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_06_142108) do
  create_table "interests", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_interests_on_name", unique: true
  end

  create_table "messages", id: :string, force: :cascade do |t|
    t.string "content", null: false
    t.datetime "created_at", null: false
    t.string "project_id"
    t.datetime "updated_at", null: false
    t.string "user_id"
    t.index ["project_id"], name: "index_messages_on_project_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "profile_interests", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "interest_id", null: false
    t.string "profile_id", null: false
    t.datetime "updated_at", null: false
    t.index ["interest_id"], name: "index_profile_interests_on_interest_id"
    t.index ["profile_id", "interest_id"], name: "index_profile_interests_on_profile_id_and_interest_id", unique: true
    t.index ["profile_id"], name: "index_profile_interests_on_profile_id"
  end

  create_table "profile_skills", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "profile_id", null: false
    t.string "skill_id", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "skill_id"], name: "index_profile_skills_on_profile_id_and_skill_id", unique: true
    t.index ["profile_id"], name: "index_profile_skills_on_profile_id"
    t.index ["skill_id"], name: "index_profile_skills_on_skill_id"
  end

  create_table "profiles", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "project_membership_requests", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "project_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.string "user_id", null: false
    t.index ["project_id"], name: "index_project_membership_requests_on_project_id"
    t.index ["user_id"], name: "index_project_membership_requests_on_user_id"
  end

  create_table "project_memberships", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "project_id"
    t.string "role", default: "member", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.string "user_id"
    t.index ["project_id"], name: "index_project_memberships_on_project_id"
    t.index ["user_id"], name: "index_project_memberships_on_user_id"
  end

  create_table "project_tags", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "project_id", null: false
    t.string "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "tag_id"], name: "index_project_tags_on_project_id_and_tag_id"
    t.index ["project_id"], name: "index_project_tags_on_project_id"
    t.index ["tag_id", "project_id"], name: "index_project_tags_on_tag_id_and_project_id", unique: true
    t.index ["tag_id"], name: "index_project_tags_on_tag_id"
  end

  create_table "projects", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.string "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "skills", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_skills_on_name", unique: true
  end

  create_table "tags", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "projects_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "profile_interests", "interests"
  add_foreign_key "profile_interests", "profiles"
  add_foreign_key "profile_skills", "profiles"
  add_foreign_key "profile_skills", "skills"
  add_foreign_key "profiles", "users"
  add_foreign_key "project_membership_requests", "projects"
  add_foreign_key "project_membership_requests", "users"
  add_foreign_key "project_tags", "projects"
  add_foreign_key "project_tags", "tags"
  add_foreign_key "sessions", "users"
end
