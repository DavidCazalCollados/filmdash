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

ActiveRecord::Schema[7.1].define(version: 2024_12_13_134544) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movie_watchlists", force: :cascade do |t|
    t.string "title"
    t.string "overview"
    t.string "release_date"
    t.string "poster_path"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "backdrop_path"
    t.string "tmdb_id"
    t.string "vote_average"
    t.string "runtime"
    t.string "trailer_youtube_key"
    t.text "watch_providers", default: "[]", null: false
    t.index ["user_id"], name: "index_movie_watchlists_on_user_id"
  end

  create_table "streaming_links", force: :cascade do |t|
    t.string "name"
    t.string "link"
    t.bigint "movie_watchlist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_watchlist_id"], name: "index_streaming_links_on_movie_watchlist_id"
  end

  create_table "streaming_services", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source_id"
  end

  create_table "user_streaming_services", force: :cascade do |t|
    t.bigint "streaming_service_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["streaming_service_id"], name: "index_user_streaming_services_on_streaming_service_id"
    t.index ["user_id"], name: "index_user_streaming_services_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "vpn", default: false, null: false
    t.bigint "country_id", null: false
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "movie_watchlists", "users"
  add_foreign_key "streaming_links", "movie_watchlists"
  add_foreign_key "user_streaming_services", "streaming_services"
  add_foreign_key "user_streaming_services", "users"
  add_foreign_key "users", "countries"
end
