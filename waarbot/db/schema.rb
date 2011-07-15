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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110713162241) do

  create_table "players", :force => true do |t|
    t.string   "name"
    t.string   "password"
    t.integer  "gold"
    t.integer  "mine"
    t.integer  "soldiers"
    t.integer  "knights"
    t.integer  "archers"
    t.string   "alliance_name"
    t.integer  "alliance_id"
    t.integer  "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "may_attack"
    t.integer  "heroes"
    t.integer  "xp"
  end

  create_table "targets", :force => true do |t|
    t.integer  "ingame_id"
    t.string   "name"
    t.integer  "xp"
    t.integer  "gold"
    t.integer  "state"
    t.integer  "population"
    t.string   "alliance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", :force => true do |t|
    t.integer  "code"
    t.string   "name"
    t.integer  "cost"
    t.integer  "attack"
    t.integer  "defense"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
