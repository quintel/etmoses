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

ActiveRecord::Schema.define(version: 20150922133347) do

  create_table "business_cases", force: true do |t|
    t.integer  "testing_ground_id"
    t.text     "financials"
    t.integer  "job_id"
    t.datetime "job_finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
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

  create_table "importable_attributes", force: true do |t|
    t.integer "technology_id"
    t.string  "name",          limit: 50
  end

  add_index "importable_attributes", ["technology_id", "name"], name: "index_importable_attributes_on_technology_id_and_name", unique: true, using: :btree

  create_table "load_profile_categories", force: true do |t|
    t.string   "name"
    t.string   "key"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "load_profile_components", force: true do |t|
    t.integer  "load_profile_id"
    t.string   "curve_type"
    t.string   "curve_file_name"
    t.string   "curve_content_type"
    t.integer  "curve_file_size"
    t.datetime "curve_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "load_profiles", force: true do |t|
    t.string   "key",                                 default: "",    null: false
    t.string   "name"
    t.boolean  "public",                              default: true,  null: false
    t.string   "user_id"
    t.integer  "load_profile_category_id"
    t.boolean  "locked",                              default: false, null: false
    t.float    "default_capacity",         limit: 24
    t.float    "default_volume",           limit: 24
    t.float    "default_demand",           limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "load_profiles", ["key"], name: "index_load_profiles_on_key", unique: true, using: :btree

  create_table "market_models", force: true do |t|
    t.string   "name"
    t.boolean  "public",       default: false
    t.integer  "user_id"
    t.text     "interactions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "price_curves", force: true do |t|
    t.string   "name"
    t.string   "key"
    t.boolean  "public",             default: true
    t.integer  "user_id"
    t.string   "curve_file_name"
    t.string   "curve_content_type"
    t.integer  "curve_file_size"
    t.datetime "curve_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "selected_strategies", force: true do |t|
    t.integer "testing_ground_id"
    t.boolean "solar_storage",                      default: false
    t.boolean "battery_storage",                    default: false
    t.boolean "solar_power_to_heat",                default: false
    t.boolean "solar_power_to_gas",                 default: false
    t.boolean "buffering_electric_car",             default: false
    t.boolean "buffering_space_heating",            default: false
    t.boolean "postponing_base_load",               default: false
    t.boolean "saving_base_load",                   default: false
    t.boolean "capping_solar_pv",                   default: false
    t.float   "capping_fraction",        limit: 24, default: 1.0
  end

  create_table "technologies", force: true do |t|
    t.string  "key",              limit: 100,                null: false
    t.string  "name",             limit: 100
    t.string  "export_to",        limit: 100
    t.string  "behavior",         limit: 50
    t.boolean "visible",                      default: true
    t.float   "default_capacity", limit: 24
    t.float   "default_volume",   limit: 24
    t.float   "default_demand",   limit: 24
  end

  add_index "technologies", ["key"], name: "index_technologies_on_key", unique: true, using: :btree

  create_table "technology_component_behaviors", force: true do |t|
    t.integer "technology_id",            null: false
    t.string  "curve_type",    limit: 50, null: false
    t.string  "behavior",      limit: 50, null: false
  end

  add_index "technology_component_behaviors", ["technology_id", "curve_type"], name: "index_technology_curve_type", unique: true, using: :btree

  create_table "technology_profiles", force: true do |t|
    t.integer "load_profile_id",              null: false
    t.string  "technology",      default: "", null: false
  end

  add_index "technology_profiles", ["load_profile_id", "technology"], name: "index_technology_profiles_on_load_profile_id_and_technology", unique: true, using: :btree
  add_index "technology_profiles", ["load_profile_id"], name: "index_technology_profiles_on_load_profile_id", using: :btree

  create_table "testing_grounds", force: true do |t|
    t.text     "technology_profile", limit: 16777215
    t.integer  "user_id"
    t.integer  "topology_id"
    t.integer  "market_model_id"
    t.boolean  "public",                              default: true, null: false
    t.integer  "parent_scenario_id"
    t.integer  "job_id"
    t.datetime "job_finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",               limit: 100,      default: "",   null: false
    t.integer  "scenario_id"
  end

  create_table "topologies", force: true do |t|
    t.string   "name"
    t.text     "graph",      limit: 16777215,                null: false
    t.boolean  "public",                      default: true, null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                              null: false
    t.string   "encrypted_password", default: "",    null: false
    t.string   "name"
    t.boolean  "activated",          default: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "admin",              default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
