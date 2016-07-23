# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160131080107) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", id: false, force: :cascade do |t|
    t.string   "id"
    t.string   "title"
    t.text     "content"
    t.text     "summary"
    t.text     "author"
    t.text     "alternate"
    t.text     "origin"
    t.text     "keywords"
    t.text     "visual"
    t.text     "tags"
    t.text     "categories"
    t.boolean  "unread",          null: false
    t.integer  "engagement"
    t.integer  "actionTimestamp"
    t.text     "enclosure"
    t.text     "fingerprint",     null: false
    t.string   "originId",        null: false
    t.string   "sid"
    t.datetime "crawled"
    t.datetime "recrawled"
    t.datetime "published"
    t.datetime "updated"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "feed_id",         null: false
  end

  add_index "entries", ["id"], name: "index_entries_on_id", unique: true, using: :btree

  create_table "feeds", id: false, force: :cascade do |t|
    t.string   "id",          null: false
    t.string   "title"
    t.text     "description"
    t.string   "website"
    t.string   "visualUrl"
    t.string   "coverUrl"
    t.string   "iconUrl"
    t.string   "language"
    t.string   "partial"
    t.string   "coverColor"
    t.string   "contentType"
    t.integer  "subscribers"
    t.float    "velocity"
    t.string   "topics"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "feeds", ["id"], name: "index_feeds_on_id", unique: true, using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "feed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",            null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
