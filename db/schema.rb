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

ActiveRecord::Schema.define(version: 20140522080806) do

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.text     "comment"
    t.integer  "id_type"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["id_type", "target_id"], name: "index_comments_on_id_type_and_target_id"

  create_table "cost_comments", force: true do |t|
    t.integer  "cost_type"
    t.text     "comment"
    t.text     "cost_memo"
    t.integer  "risk_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "probability"
    t.integer  "influence"
    t.integer  "priority"
  end

  add_index "cost_comments", ["cost_type", "risk_id"], name: "index_cost_comments_on_cost_type_and_risk_id"

  create_table "limit_apis", force: true do |t|
    t.string   "api"
    t.integer  "counter"
    t.datetime "counted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "limit_apis", ["api"], name: "index_limit_apis_on_api", unique: true

  create_table "password_reset_hashes", force: true do |t|
    t.integer  "user_id"
    t.string   "hash_pass"
    t.boolean  "enable_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "password_reset_hashes", ["hash_pass"], name: "index_password_reset_hashes_on_hash_pass"
  add_index "password_reset_hashes", ["user_id"], name: "index_password_reset_hashes_on_user_id", unique: true

  create_table "projects", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "risks", force: true do |t|
    t.string   "title"
    t.text     "details"
    t.integer  "status"
    t.integer  "check_cycle"
    t.date     "watch_over_date"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "next_check_date"
    t.integer  "priority"
  end

  add_index "risks", ["project_id", "next_check_date"], name: "index_risks_on_project_id_and_next_check_date"

  create_table "users", force: true do |t|
    t.string   "nickname"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.string   "email"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["nickname"], name: "index_users_on_nickname", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
