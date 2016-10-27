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

ActiveRecord::Schema.define(version: 20161027142125) do

  create_table "asset_lists", force: true do |t|
    t.integer  "testing_ground_id"
    t.string   "type",              limit: 40, null: false
    t.text     "asset_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business_cases", force: true do |t|
    t.integer  "testing_ground_id"
    t.text     "financials"
    t.integer  "job_id"
    t.datetime "job_finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",                      default: 0, null: false
    t.integer  "attempts",                      default: 0, null: false
    t.text     "handler",    limit: 2147483647,             null: false
    t.text     "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

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
    t.boolean  "included_in_concurrency",             default: false
  end

  add_index "load_profiles", ["key"], name: "index_load_profiles_on_key", unique: true, using: :btree

  create_table "market_models", force: true do |t|
    t.string   "name"
    t.boolean  "public",       default: false
    t.integer  "user_id"
    t.integer  "original_id"
    t.text     "interactions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.string   "type"
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
    t.boolean "battery_storage",                    default: false
    t.boolean "ev_capacity_constrained",            default: false
    t.boolean "ev_excess_constrained",              default: false
    t.boolean "ev_storage",                         default: false
    t.boolean "solar_power_to_heat",                default: false
    t.boolean "solar_power_to_gas",                 default: false
    t.boolean "hp_capacity_constrained",            default: false
    t.boolean "hhp_switch_to_gas",                  default: false
    t.boolean "postponing_base_load",               default: false
    t.boolean "saving_base_load",                   default: false
    t.boolean "capping_solar_pv",                   default: false
    t.float   "capping_fraction",        limit: 24, default: 1.0
  end

  create_table "stakeholders", force: true do |t|
    t.string  "name"
    t.integer "parent_id"
  end

  create_table "technology_profiles", force: true do |t|
    t.integer "load_profile_id",              null: false
    t.string  "technology",      default: "", null: false
  end

  add_index "technology_profiles", ["load_profile_id", "technology"], name: "index_technology_profiles_on_load_profile_id_and_technology", unique: true, using: :btree
  add_index "technology_profiles", ["load_profile_id"], name: "index_technology_profiles_on_load_profile_id", using: :btree

  create_table "testing_ground_delayed_jobs", force: true do |t|
    t.integer "testing_ground_id"
    t.integer "job_id"
    t.string  "job_type"
  end

  create_table "testing_grounds", force: true do |t|
    t.text     "technology_profile",           limit: 16777215
    t.integer  "user_id"
    t.integer  "topology_id"
    t.integer  "market_model_id"
    t.integer  "behavior_profile_id"
    t.float    "central_heat_buffer_capacity", limit: 24
    t.boolean  "public",                                        default: true, null: false
    t.integer  "parent_scenario_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "cache_updated_at"
    t.string   "name",                         limit: 100,      default: "",   null: false
    t.integer  "scenario_id"
    t.integer  "range_start",                                   default: 0
    t.integer  "range_end",                                     default: 672
  end

  create_table "topologies", force: true do |t|
    t.string   "name"
    t.text     "graph",       limit: 16777215,                null: false
    t.boolean  "public",                       default: true, null: false
    t.integer  "user_id"
    t.integer  "original_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                                  null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "name"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
