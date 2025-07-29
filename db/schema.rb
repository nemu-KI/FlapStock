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

ActiveRecord::Schema[7.1].define(version: 2025_07_29_135626) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_categories_on_company_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.integer "stock_quantity", default: 0, null: false
    t.string "unit", null: false
    t.bigint "category_id", null: false
    t.bigint "location_id", null: false
    t.bigint "supplier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.text "description"
    t.string "sku"
    t.string "image_url"
    t.integer "min_stock"
    t.integer "max_stock"
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["company_id"], name: "index_items_on_company_id"
    t.index ["location_id"], name: "index_items_on_location_id"
    t.index ["supplier_id"], name: "index_items_on_supplier_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_locations_on_company_id"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.integer "movement_category", null: false
    t.integer "quantity", null: false
    t.string "reason"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.bigint "user_id", null: false
    t.index ["company_id"], name: "index_stock_movements_on_company_id"
    t.index ["item_id"], name: "index_stock_movements_on_item_id"
    t.index ["user_id"], name: "index_stock_movements_on_user_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.string "phone", limit: 20
    t.string "address"
    t.string "contact_person"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_suppliers_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "role"
    t.bigint "company_id"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "companies"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "companies"
  add_foreign_key "items", "locations"
  add_foreign_key "items", "suppliers"
  add_foreign_key "locations", "companies"
  add_foreign_key "stock_movements", "companies"
  add_foreign_key "stock_movements", "items"
  add_foreign_key "stock_movements", "users"
  add_foreign_key "suppliers", "companies"
  add_foreign_key "users", "companies"
end
