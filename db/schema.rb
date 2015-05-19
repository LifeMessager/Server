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

ActiveRecord::Schema.define(version: 20150520071924) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "mail_receivers", force: :cascade do |t|
    t.string   "address",     limit: 255,             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                             null: false
    t.string   "timezone",    limit: 255,             null: false
    t.date     "locale_date",                         null: false
    t.integer  "notes_count",             default: 0
  end

  add_index "mail_receivers", ["user_id"], name: "index_mail_receivers_on_user_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.string   "from_email",       limit: 255, null: false
    t.text     "content",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mail_receiver_id",             null: false
    t.string   "type",             limit: 255
  end

  add_index "notes", ["mail_receiver_id"], name: "index_notes_on_mail_receiver_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",             limit: 255,                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "subscribed",                    default: true
    t.string   "unsubscribe_token", limit: 255,                   null: false
    t.string   "timezone",          limit: 255,                   null: false
    t.string   "language",          limit: 255,                   null: false
    t.boolean  "email_verified",                default: false,   null: false
    t.string   "alert_time",        limit: 255, default: "08:00", null: false
    t.datetime "deleted_at"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree

  add_foreign_key "mail_receivers", "users"
  add_foreign_key "notes", "mail_receivers"
end
