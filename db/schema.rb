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

ActiveRecord::Schema.define(version: 20181120042833) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "uuid-ossp"

  create_table "album_artist_identities", force: :cascade do |t|
    t.uuid "album_identity_id", null: false
    t.uuid "artist_identity_id", null: false
    t.index ["album_identity_id", "artist_identity_id"], name: "index_album_artist_identities", unique: true
  end

  create_table "album_identities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "artist_name", null: false
    t.string "slug", null: false
    t.integer "entries_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "saved_count", default: 0, null: false
    t.integer "play_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "artist_name"], name: "index_album_identities_on_name_and_artist_name", unique: true
    t.index ["name"], name: "index_album_identities_on_name"
    t.index ["slug"], name: "index_album_identities_on_slug", unique: true
  end

  create_table "album_track_identities", force: :cascade do |t|
    t.uuid "album_identity_id", null: false
    t.uuid "track_identity_id", null: false
    t.index ["album_identity_id", "track_identity_id"], name: "index_album_track_identities", unique: true
  end

  create_table "album_tracks", force: :cascade do |t|
    t.uuid "album_id", null: false
    t.uuid "track_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["album_id", "track_id"], name: "index_album_tracks_on_album_id_and_track_id", unique: true
    t.index ["created_at"], name: "index_album_tracks_on_created_at"
    t.index ["updated_at"], name: "index_album_tracks_on_updated_at"
  end

  create_table "albums", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "provider", default: 0, null: false
    t.string "identifier", default: "", null: false
    t.string "owner_id"
    t.string "owner_name"
    t.string "url", default: "", null: false
    t.string "title", default: "", null: false
    t.string "description"
    t.string "thumbnail_url"
    t.string "artwork_url"
    t.datetime "published_at"
    t.string "state"
    t.integer "entries_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "saved_count", default: 0, null: false
    t.integer "play_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identity_id"
    t.index ["identity_id"], name: "index_albums_on_identity_id"
    t.index ["provider"], name: "index_albums_on_provider"
    t.index ["title"], name: "index_albums_on_title"
  end

  create_table "artist_aliases", force: :cascade do |t|
    t.uuid "artist_identity_id", null: false
    t.string "name", null: false
    t.index ["artist_identity_id", "name"], name: "index_artist_aliases_on_artist_identity_id_and_name", unique: true
    t.index ["name"], name: "index_artist_aliases_on_name"
  end

  create_table "artist_identities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "origin_name", null: false
    t.string "slug", null: false
    t.text "bio"
    t.string "wikipedia"
    t.string "website"
    t.string "facebook"
    t.string "instagram"
    t.string "twitter"
    t.integer "entries_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "saved_count", default: 0, null: false
    t.integer "play_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_artist_identities_on_name"
    t.index ["slug"], name: "index_artist_identities_on_slug", unique: true
  end

  create_table "artists", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "provider", default: 0
    t.string "identifier", default: "", null: false
    t.string "url", default: "", null: false
    t.string "thumbnail_url"
    t.string "artwork_url"
    t.integer "entries_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "saved_count", default: 0, null: false
    t.integer "play_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identity_id"
    t.index ["identity_id"], name: "index_artists_on_identity_id"
    t.index ["name"], name: "index_artists_on_name"
    t.index ["provider"], name: "index_artists_on_provider"
  end

  create_table "authentications", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.integer "provider", null: false
    t.string "uid", null: false
    t.string "name"
    t.string "nickname"
    t.string "email"
    t.string "url"
    t.string "image_url"
    t.string "description"
    t.text "others"
    t.text "credentials"
    t.text "raw_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_authentications_on_provider_and_uid", unique: true
    t.index ["provider"], name: "index_authentications_on_provider"
    t.index ["user_id", "provider"], name: "index_authentications_on_user_id_and_provider", unique: true
  end

  create_table "categories", id: false, force: :cascade do |t|
    t.string "id", null: false
    t.string "label", null: false
    t.string "description"
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_categories_on_id", unique: true
    t.index ["label"], name: "index_categories_on_label", unique: true
  end

  create_table "enclosure_artists", force: :cascade do |t|
    t.uuid "enclosure_id", null: false
    t.string "enclosure_type", null: false
    t.uuid "artist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_enclosure_artists_on_created_at"
    t.index ["enclosure_id", "artist_id"], name: "index_enclosure_artists_on_enclosure_id_and_artist_id", unique: true
    t.index ["updated_at"], name: "index_enclosure_artists_on_updated_at"
  end

  create_table "enclosure_issues", id: :serial, force: :cascade do |t|
    t.string "enclosure_type", null: false
    t.uuid "enclosure_id", null: false
    t.uuid "issue_id", null: false
    t.integer "engagement", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enclosure_id", "issue_id"], name: "index_enclosure_issues_on_enclosure_id_and_issue_id", unique: true
  end

  create_table "enclosures", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "entries_count", default: 0, null: false
    t.string "type", default: "Track", null: false
    t.integer "saved_count", default: 0, null: false
    t.integer "play_count", default: 0, null: false
    t.integer "provider", default: 0
    t.string "title", default: ""
    t.integer "pick_count", default: 0, null: false
    t.index ["id"], name: "index_enclosures_on_id", unique: true
    t.index ["provider"], name: "index_enclosures_on_provider"
    t.index ["title"], name: "index_enclosures_on_title"
    t.index ["type"], name: "index_enclosures_on_type"
  end

  create_table "entries", id: false, force: :cascade do |t|
    t.string "id"
    t.string "title"
    t.text "content"
    t.text "summary"
    t.text "author"
    t.text "alternate"
    t.text "origin"
    t.text "keywords"
    t.text "visual"
    t.integer "engagement"
    t.text "enclosure"
    t.text "fingerprint", null: false
    t.string "originId", null: false
    t.datetime "crawled"
    t.datetime "recrawled"
    t.datetime "published"
    t.datetime "updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "feed_id", null: false
    t.integer "saved_count", default: 0, null: false
    t.integer "read_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.index ["crawled"], name: "index_entries_on_crawled"
    t.index ["feed_id"], name: "index_entries_on_feed_id"
    t.index ["id"], name: "index_entries_on_id", unique: true
    t.index ["originId"], name: "index_entries_on_originId"
    t.index ["published"], name: "index_entries_on_published"
    t.index ["recrawled"], name: "index_entries_on_recrawled"
    t.index ["updated"], name: "index_entries_on_updated"
  end

  create_table "entry_enclosures", id: :serial, force: :cascade do |t|
    t.string "entry_id", null: false
    t.uuid "enclosure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "enclosure_type", default: "Track", null: false
    t.integer "engagement", default: 0, null: false
    t.integer "enclosure_provider", default: 0
    t.index ["enclosure_id"], name: "index_entry_enclosures_on_enclosure_id"
    t.index ["enclosure_type"], name: "index_entry_enclosures_on_enclosure_type"
    t.index ["entry_id", "enclosure_id"], name: "index_entry_enclosures_on_entry_id_and_enclosure_id", unique: true
    t.index ["entry_id"], name: "index_entry_enclosures_on_entry_id"
  end

  create_table "entry_issues", id: :serial, force: :cascade do |t|
    t.string "entry_id", null: false
    t.uuid "issue_id", null: false
    t.integer "engagement", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id", "issue_id"], name: "index_entry_issues_on_entry_id_and_issue_id", unique: true
  end

  create_table "entry_tags", id: :serial, force: :cascade do |t|
    t.string "tag_id"
    t.string "entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feed_topics", id: :serial, force: :cascade do |t|
    t.string "feed_id"
    t.string "topic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feed_id", "topic_id"], name: "index_feed_topics_on_feed_id_and_topic_id", unique: true
  end

  create_table "feeds", id: false, force: :cascade do |t|
    t.string "id", null: false
    t.string "title"
    t.text "description"
    t.string "website"
    t.string "visualUrl"
    t.string "coverUrl"
    t.string "iconUrl"
    t.string "language"
    t.string "partial"
    t.string "coverColor"
    t.string "contentType"
    t.integer "subscribers"
    t.float "velocity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "crawled"
    t.datetime "lastUpdated"
    t.index ["id"], name: "index_feeds_on_id", unique: true
  end

  create_table "genre_items", force: :cascade do |t|
    t.integer "genre_id", null: false
    t.uuid "genre_item_id", null: false
    t.string "genre_item_type", null: false
    t.index ["genre_id", "genre_item_id"], name: "index_genre_items_on_genre_id_and_genre_item_id"
  end

  create_table "genres", force: :cascade do |t|
    t.string "label", null: false
    t.string "japanese_label"
    t.index ["label"], name: "index_genres_on_label"
  end

  create_table "issues", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "label", null: false
    t.text "description"
    t.integer "state", default: 0, null: false
    t.uuid "journal_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_issues_on_id", unique: true
    t.index ["journal_id", "label"], name: "index_issues_on_journal_id_and_label", unique: true
  end

  create_table "journals", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "stream_id", null: false
    t.string "label", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_journals_on_id", unique: true
    t.index ["label"], name: "index_journals_on_label", unique: true
  end

  create_table "keywordables", id: :serial, force: :cascade do |t|
    t.string "keywordable_id", null: false
    t.string "keyword_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "keywordable_type", default: "Entry", null: false
    t.index ["keywordable_id", "keyword_id"], name: "index_keywordables_on_keywordable_id_and_keyword_id", unique: true
  end

  create_table "keywords", id: false, force: :cascade do |t|
    t.string "id", null: false
    t.string "label", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_keywords_on_id", unique: true
    t.index ["label"], name: "index_keywords_on_label", unique: true
  end

  create_table "liked_enclosures", id: :serial, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "enclosure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "enclosure_type", default: "Track", null: false
    t.index ["enclosure_type"], name: "index_liked_enclosures_on_enclosure_type"
    t.index ["user_id", "enclosure_id"], name: "index_liked_enclosures_on_user_id_and_enclosure_id", unique: true
  end

  create_table "liked_entries", id: :serial, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "entry_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "entry_id"], name: "index_liked_entries_on_user_id_and_entry_id", unique: true
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.uuid "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.uuid "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "picks", force: :cascade do |t|
    t.uuid "enclosure_id", null: false
    t.string "enclosure_type", null: false
    t.uuid "container_id", null: false
    t.string "container_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_picks_on_created_at"
    t.index ["enclosure_id", "container_id"], name: "index_picks_on_enclosure_id_and_container_id", unique: true
    t.index ["updated_at"], name: "index_picks_on_updated_at"
  end

  create_table "played_enclosures", id: :serial, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "enclosure_id", null: false
    t.string "enclosure_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "enclosure_id"], name: "index_played_enclosures_on_user_id_and_enclosure_id"
  end

  create_table "playlists", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "provider", default: 0, null: false
    t.string "identifier", default: "", null: false
    t.string "owner_id"
    t.string "owner_name"
    t.string "url", default: "", null: false
    t.string "title", default: "", null: false
    t.string "description"
    t.float "velocity", default: 0.0, null: false
    t.string "thumbnail_url"
    t.string "artwork_url"
    t.datetime "published_at"
    t.string "state"
    t.integer "entries_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "saved_count", default: 0, null: false
    t.integer "play_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider"], name: "index_playlists_on_provider"
    t.index ["title"], name: "index_playlists_on_title"
  end

  create_table "preferences", id: :serial, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "key", null: false
    t.text "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "key"], name: "index_preferences_on_user_id_and_key", unique: true
  end

  create_table "read_entries", id: :serial, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "entry_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "entry_id"], name: "index_read_entries_on_user_id_and_entry_id", unique: true
  end

  create_table "resources", id: :serial, force: :cascade do |t|
    t.string "wall_id", null: false
    t.string "resource_id", null: false
    t.integer "resource_type", null: false
    t.integer "engagement", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "options"
  end

  create_table "saved_enclosures", id: :serial, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "enclosure_id", null: false
    t.string "enclosure_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "enclosure_id"], name: "index_saved_enclosures_on_user_id_and_enclosure_id", unique: true
  end

  create_table "saved_entries", id: :serial, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "entry_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "entry_id"], name: "index_saved_entries_on_user_id_and_entry_id", unique: true
  end

  create_table "subscription_categories", id: :serial, force: :cascade do |t|
    t.integer "subscription_id"
    t.string "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id", "category_id"], name: "subscription_categories_index", unique: true
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "feed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "feed_id"], name: "index_subscriptions_on_user_id_and_feed_id", unique: true
  end

  create_table "tags", id: false, force: :cascade do |t|
    t.string "id", null: false
    t.string "user_id", null: false
    t.string "label", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_tags_on_id", unique: true
    t.index ["user_id", "label"], name: "index_tags_on_user_id_and_label", unique: true
  end

  create_table "topics", id: false, force: :cascade do |t|
    t.string "id", null: false
    t.string "label", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "engagement", default: 0, null: false
    t.integer "mix_duration", default: 259200, null: false
    t.string "locale"
    t.index ["id"], name: "index_topics_on_id", unique: true
    t.index ["label"], name: "index_topics_on_label", unique: true
    t.index ["locale"], name: "index_topics_on_locale"
  end

  create_table "track_artist_identities", force: :cascade do |t|
    t.uuid "track_identity_id", null: false
    t.uuid "artist_identity_id", null: false
    t.index ["track_identity_id", "artist_identity_id"], name: "index_track_artist_identities", unique: true
  end

  create_table "track_identities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "artist_name", null: false
    t.string "slug", null: false
    t.integer "entries_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "saved_count", default: 0, null: false
    t.integer "play_count", default: 0, null: false
    t.integer "pick_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "artist_name"], name: "index_track_identities_on_name_and_artist_name", unique: true
    t.index ["name"], name: "index_track_identities_on_name"
    t.index ["slug"], name: "index_track_identities_on_slug", unique: true
  end

  create_table "tracks", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "provider", default: 0, null: false
    t.string "identifier", default: "", null: false
    t.string "owner_id"
    t.string "owner_name"
    t.string "url", default: "", null: false
    t.string "title", default: "", null: false
    t.string "description"
    t.string "thumbnail_url"
    t.string "artwork_url"
    t.string "audio_url"
    t.integer "duration"
    t.datetime "published_at"
    t.string "state"
    t.integer "entries_count", default: 0, null: false
    t.integer "pick_count", default: 0, null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "saved_count", default: 0, null: false
    t.integer "play_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "identity_id"
    t.index ["identity_id"], name: "index_tracks_on_identity_id"
    t.index ["provider"], name: "index_tracks_on_provider"
    t.index ["title"], name: "index_tracks_on_title"
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type"
    t.string "name"
    t.string "picture"
    t.string "locale"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["id"], name: "index_users_on_id", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  create_table "walls", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
