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

ActiveRecord::Schema[7.1].define(version: 2024_08_02_184419) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "post_status", %w[pending success failed]

  create_table "articles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "source_platform", null: false
    t.string "external_id", null: false
    t.string "title", null: false
    t.string "article_url", null: false
    t.datetime "published_at", null: false
    t.integer "likes_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_postable", default: false
    t.integer "post_count", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.index %w[external_id source_platform], name: "index_articles_on_external_id_and_source_platform", unique: true
    t.index %w[user_id is_postable is_active published_at likes_count], name: "index_articles_on_user_postable_active_published_likes"
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.enum "status", default: "pending", null: false, enum_type: "post_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["article_id"], name: "index_posts_on_article_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "mattermost_id", null: false
    t.string "qiita_username"
    t.string "zenn_username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "x_username"
    t.index ["mattermost_id"], name: "index_users_on_mattermost_id", unique: true
    t.index %w[qiita_username zenn_username], name: "index_users_on_qiita_and_zenn_usernames"
    t.index ["qiita_username"], name: "index_users_on_qiita_username"
    t.index ["x_username"], name: "index_users_on_x_username"
    t.index ["zenn_username"], name: "index_users_on_zenn_username"
  end

  add_foreign_key "articles", "users"
  add_foreign_key "posts", "articles"
  add_foreign_key "posts", "users"
end
