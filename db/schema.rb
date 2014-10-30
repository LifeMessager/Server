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

ActiveRecord::Schema.define(version: 20141028073853) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "mail_receivers", force: true do |t|
    t.string   "address",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",    null: false
    t.string   "timezone",   null: false
  end

  add_index "mail_receivers", ["user_id"], name: "index_mail_receivers_on_user_id", using: :btree

  create_table "notes", force: true do |t|
    t.string   "from_email",       null: false
    t.text     "content",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mail_receiver_id", null: false
  end

  add_index "notes", ["mail_receiver_id"], name: "index_notes_on_mail_receiver_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "subscribed",        default: true
    t.string   "unsubscribe_token",                null: false
    t.string   "timezone",                         null: false
    t.datetime "alert_time",                       null: false
  end

end
