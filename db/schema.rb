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

ActiveRecord::Schema[7.1].define(version: 2024_12_02_010800) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "announcement_reads", force: :cascade do |t|
    t.bigint "announcement_id", null: false
    t.bigint "user_id", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["announcement_id"], name: "index_announcement_reads_on_announcement_id"
    t.index ["user_id"], name: "index_announcement_reads_on_user_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "status", default: "draft"
    t.datetime "published_at"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "price_in_cents", null: false
    t.string "stripe_product_id"
    t.string "stripe_price_id"
    t.boolean "published", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "product_type", default: "subscription"
    t.string "billing_period"
    t.boolean "archived", default: false
    t.index ["archived"], name: "index_products_on_archived"
    t.index ["published"], name: "index_products_on_published"
    t.index ["stripe_price_id"], name: "index_products_on_stripe_price_id", unique: true
    t.index ["stripe_product_id"], name: "index_products_on_stripe_product_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "announcement_reads", "announcements"
  add_foreign_key "announcement_reads", "users"
  add_foreign_key "announcements", "users"
end
