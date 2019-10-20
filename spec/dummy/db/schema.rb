# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 20_190_217_061_814) do
  create_table 'admins', force: :cascade do |t|
    t.string 'email'
    t.string 'password_digest'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'token_issued_at'
  end

  create_table 'blacklisted_tokens', force: :cascade do |t|
    t.string 'token'
    t.datetime 'expire_at'
    t.integer 'user_id'
    t.integer 'admin_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['admin_id'], name: 'index_blacklisted_tokens_on_admin_id'
    t.index ['user_id'], name: 'index_blacklisted_tokens_on_user_id'
  end

  create_table 'posts', force: :cascade do |t|
    t.integer 'user_id'
    t.text 'content'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_posts_on_user_id'
  end

  create_table 'refresh_tokens', force: :cascade do |t|
    t.string 'token'
    t.integer 'user_id'
    t.integer 'admin_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['admin_id'], name: 'index_refresh_tokens_on_admin_id'
    t.index ['token'], name: 'index_refresh_tokens_on_token', unique: true
    t.index ['user_id'], name: 'index_refresh_tokens_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email'
    t.string 'password_digest'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'token_issued_at'
  end
end
