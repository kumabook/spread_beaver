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

ActiveRecord::Schema.define(version: 20160117154118) do

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
