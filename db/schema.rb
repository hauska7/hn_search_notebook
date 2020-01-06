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

ActiveRecord::Schema.define(version: 2020_01_06_072513) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "results_in_notebooks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "search_result_id", null: false
    t.bigint "search_notebook_id", null: false
    t.index ["search_notebook_id"], name: "index_results_in_notebooks_on_search_notebook_id"
    t.index ["search_result_id"], name: "index_results_in_notebooks_on_search_result_id"
  end

  create_table "search_notebooks", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "search_queries", force: :cascade do |t|
    t.string "query", null: false
    t.integer "total_hits_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "search_results", force: :cascade do |t|
    t.string "hn_login", null: false
    t.string "url", null: false
    t.integer "author_karma_points"
    t.string "tags", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "search_query_id", null: false
    t.index ["search_query_id"], name: "index_search_results_on_search_query_id"
  end

  add_foreign_key "results_in_notebooks", "search_notebooks"
  add_foreign_key "results_in_notebooks", "search_results"
  add_foreign_key "search_results", "search_queries"
end
