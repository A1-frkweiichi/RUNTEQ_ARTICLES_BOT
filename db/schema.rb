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

ActiveRecord::Schema[7.1].define(version: 2024_06_28_144708) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "mattermost_id", null: false
    t.string "qiita_username"
    t.string "zenn_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mattermost_id"], name: "index_users_on_mattermost_id", unique: true
    t.index ["qiita_username"], name: "index_users_on_qiita_username"
    t.index ["zenn_username"], name: "index_users_on_zenn_username"
  end

end
