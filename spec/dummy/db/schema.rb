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

ActiveRecord::Schema.define(version: 2022_07_12_180445) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dummy_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "stripe_customer_id"
    t.datetime "remember_created_at"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_dummy_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_dummy_users_on_reset_password_token", unique: true
  end

  create_table "flatirons_saas_products", force: :cascade do |t|
    t.string "name"
    t.string "stripe_product_id"
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_flatirons_saas_products_on_name"
    t.index ["stripe_product_id"], name: "index_flatirons_saas_products_on_stripe_product_id"
  end

  create_table "flatirons_saas_subscriptions", force: :cascade do |t|
    t.string "stripe_subscription_id", null: false
    t.string "status", null: false
    t.string "subscriptable_type"
    t.bigint "subscriptable_id"
    t.datetime "deleted_at"
    t.datetime "canceled_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["deleted_at"], name: "index_flatirons_saas_subscriptions_on_deleted_at"
    t.index ["status"], name: "index_flatirons_saas_subscriptions_on_status"
    t.index ["stripe_subscription_id"], name: "index_flatirons_saas_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["subscriptable_type", "subscriptable_id"], name: "index_flatirons_saas_subscriptions_on_subscriptable"
  end

end
