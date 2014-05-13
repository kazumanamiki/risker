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

ActiveRecord::Schema.define(version: 20140410093240) do

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
  end

  add_index "cost_comments", ["cost_type", "risk_id"], name: "index_cost_comments_on_cost_type_and_risk_id"

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
  end

  create_table "users", force: true do |t|
    t.string   "nickname"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["nickname"], name: "index_users_on_nickname", unique: true

end
