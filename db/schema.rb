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

ActiveRecord::Schema.define(version: 2022_01_06_074100) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_audit_trails", force: :cascade do |t|
    t.string "email"
    t.boolean "super_admin"
    t.string "roles_titles"
    t.datetime "login_time"
    t.datetime "logout_time"
    t.bigint "admin_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["admin_id"], name: "index_admin_audit_trails_on_admin_id"
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "super_admin", default: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "admins_roles", id: false, force: :cascade do |t|
    t.bigint "admin_id"
    t.bigint "role_id"
    t.index ["admin_id", "role_id"], name: "index_admins_roles_on_admin_id_and_role_id"
    t.index ["admin_id"], name: "index_admins_roles_on_admin_id"
    t.index ["role_id"], name: "index_admins_roles_on_role_id"
  end

  create_table "app_authorizations", force: :cascade do |t|
    t.string "access_token", null: false
    t.string "secret", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "client_id"
    t.string "refresh_token"
  end

  create_table "archive_documents", force: :cascade do |t|
    t.string "filename"
    t.string "file_path"
    t.bigint "document_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["document_id"], name: "index_archive_documents_on_document_id"
  end

  create_table "audit_trails", force: :cascade do |t|
    t.string "resource_type"
    t.string "action"
    t.string "document_ids"
    t.string "user"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "document_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string "filename"
    t.string "file_path"
    t.string "mode", null: false
    t.string "document_type", null: false
    t.string "classification", null: false
    t.text "description"
    t.string "document_number", null: false
    t.string "issuer", null: false
    t.string "recipient", null: false
    t.string "recipient_id_type", null: false
    t.datetime "issue_date", null: false
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.string "reference_type"
    t.string "reference_number"
    t.string "other_reference_type"
    t.string "other_reference_number"
    t.text "issuer_signature_1"
    t.string "issuer_sign_name_1"
    t.datetime "issuer_sign_datetime_1"
    t.text "issuer_signature_2"
    t.string "issuer_sign_name_2"
    t.datetime "issuer_sign_datetime_2"
    t.text "recipient_signature_1"
    t.string "recipient_sign_name_1"
    t.datetime "recipient_sign_datetime_1"
    t.text "recipient_signature_2"
    t.string "recipient_sign_name_2"
    t.datetime "recipient_sign_datetime_2"
    t.text "witness_signature"
    t.string "witness_sign_name"
    t.datetime "witness_sign_datetime"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "archived", default: false
    t.string "issuer_signature_1_filename"
    t.string "issuer_signature_2_filename"
    t.string "recipient_signature_1_filename"
    t.string "recipient_signature_2_filename"
    t.string "witness_signature_filename"
    t.boolean "is_temp", default: false
    t.string "sender"
    t.string "identifier"
    t.string "prefix"
    t.string "identifier_key"
    t.string "delivery_channel"
    t.boolean "should_send_notification", default: false
  end

  create_table "file_servers", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.string "filename"
    t.string "identifier"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["document_id"], name: "index_file_servers_on_document_id"
  end

  create_table "publisher_emails", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type"
    t.string "{:null=>false}"
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.json "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "archive_documents", "documents"
  add_foreign_key "file_servers", "documents"
end
