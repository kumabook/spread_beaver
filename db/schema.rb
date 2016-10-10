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

ActiveRecord::Schema.define(version: 20161010170619) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "categories", id: false, force: :cascade do |t|
    t.string   "id",          null: false
    t.string   "label",       null: false
    t.string   "description"
    t.uuid     "user_id",     null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "categories", ["id"], name: "index_categories_on_id", unique: true, using: :btree
  add_index "categories", ["label"], name: "index_categories_on_label", unique: true, using: :btree

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
    t.text     "categories"
    t.boolean  "unread",                      null: false
    t.integer  "engagement"
    t.integer  "actionTimestamp"
    t.text     "enclosure"
    t.text     "fingerprint",                 null: false
    t.string   "originId",                    null: false
    t.string   "sid"
    t.datetime "crawled"
    t.datetime "recrawled"
    t.datetime "published"
    t.datetime "updated"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "feed_id",                     null: false
    t.integer  "saved_count",     default: 0, null: false
  end

  add_index "entries", ["id"], name: "index_entries_on_id", unique: true, using: :btree

  create_table "entry_issues", force: :cascade do |t|
    t.string   "entry_id",               null: false
    t.uuid     "issue_id",               null: false
    t.integer  "engagement", default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "entry_issues", ["entry_id", "issue_id"], name: "index_entry_issues_on_entry_id_and_issue_id", unique: true, using: :btree

  create_table "entry_keywords", force: :cascade do |t|
    t.string   "entry_id",   null: false
    t.string   "keyword_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "entry_keywords", ["entry_id", "keyword_id"], name: "index_entry_keywords_on_entry_id_and_keyword_id", unique: true, using: :btree

  create_table "entry_tags", force: :cascade do |t|
    t.string   "tag_id"
    t.string   "entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entry_tracks", force: :cascade do |t|
    t.string   "entry_id",   null: false
    t.uuid     "track_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "entry_tracks", ["entry_id", "track_id"], name: "index_entry_tracks_on_entry_id_and_track_id", unique: true, using: :btree

  create_table "feed_topics", force: :cascade do |t|
    t.string   "feed_id"
    t.string   "topic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "feed_topics", ["feed_id", "topic_id"], name: "index_feed_topics_on_feed_id_and_topic_id", unique: true, using: :btree

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
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "crawled"
    t.datetime "lastUpdated"
  end

  add_index "feeds", ["id"], name: "index_feeds_on_id", unique: true, using: :btree

  create_table "issues", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "label",                   null: false
    t.text     "description"
    t.integer  "state",       default: 0, null: false
    t.uuid     "journal_id",              null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "issues", ["id"], name: "index_issues_on_id", unique: true, using: :btree
  add_index "issues", ["journal_id", "label"], name: "index_issues_on_journal_id_and_label", unique: true, using: :btree

  create_table "journals", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "stream_id",   null: false
    t.string   "label",       null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "journals", ["id"], name: "index_journals_on_id", unique: true, using: :btree
  add_index "journals", ["label"], name: "index_journals_on_label", unique: true, using: :btree

  create_table "keywords", id: false, force: :cascade do |t|
    t.string   "id",          null: false
    t.string   "label",       null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "keywords", ["id"], name: "index_keywords_on_id", unique: true, using: :btree
  add_index "keywords", ["label"], name: "index_keywords_on_label", unique: true, using: :btree

  create_table "likes", force: :cascade do |t|
    t.uuid     "user_id",    null: false
    t.uuid     "track_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "likes", ["user_id", "track_id"], name: "index_likes_on_user_id_and_track_id", unique: true, using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.uuid     "resource_owner_id", null: false
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
    t.uuid     "resource_owner_id"
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

  create_table "preferences", force: :cascade do |t|
    t.uuid     "user_id",    null: false
    t.string   "key",        null: false
    t.text     "value",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "preferences", ["user_id", "key"], name: "index_preferences_on_user_id_and_key", unique: true, using: :btree

  create_table "read_entries", force: :cascade do |t|
    t.uuid     "user_id",    null: false
    t.string   "entry_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "read_entries", ["user_id", "entry_id"], name: "index_read_entries_on_user_id_and_entry_id", unique: true, using: :btree

  create_table "saved_entries", force: :cascade do |t|
    t.uuid     "user_id",    null: false
    t.string   "entry_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "saved_entries", ["user_id", "entry_id"], name: "index_saved_entries_on_user_id_and_entry_id", unique: true, using: :btree

  create_table "subscription_categories", force: :cascade do |t|
    t.integer  "subscription_id"
    t.string   "category_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "subscription_categories", ["subscription_id", "category_id"], name: "subscription_categories_index", unique: true, using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.uuid     "user_id",    null: false
    t.string   "feed_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "subscriptions", ["user_id", "feed_id"], name: "index_subscriptions_on_user_id_and_feed_id", unique: true, using: :btree

  create_table "tags", id: false, force: :cascade do |t|
    t.string   "id",          null: false
    t.string   "user_id",     null: false
    t.string   "label",       null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "tags", ["id"], name: "index_tags_on_id", unique: true, using: :btree
  add_index "tags", ["user_id", "label"], name: "index_tags_on_user_id_and_label", unique: true, using: :btree

  create_table "topics", id: false, force: :cascade do |t|
    t.string   "id",                      null: false
    t.string   "label",                   null: false
    t.string   "description"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "engagement",  default: 0, null: false
  end

  add_index "topics", ["id"], name: "index_topics_on_id", unique: true, using: :btree
  add_index "topics", ["label"], name: "index_topics_on_label", unique: true, using: :btree

  create_table "tracks", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "identifier"
    t.string   "provider"
    t.string   "title"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tracks", ["id"], name: "index_tracks_on_id", unique: true, using: :btree
  add_index "tracks", ["provider", "identifier"], name: "index_tracks_on_provider_and_identifier", unique: true, using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "email",            null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["id"], name: "index_users_on_id", unique: true, using: :btree

end
