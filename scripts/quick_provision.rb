#!/usr/bin/env ruby
# frozen_string_literal: true

# RAILS_ENV=production exec ruby scripts/quick_provision FILENAME.json

require 'json'
require_relative '../config/environment.rb'
require_relative '../app/helpers/heal_follow_helper'

include HealFollowHelper


def error!(e)
  p 'ruby scripts/quick_provision FILE.json'
  p 'MUST INCLUDE A JSON FILE AS FIRST ARGUMENT WITH FORMAT MATCHING: '
  puts '
        [
          {
            "name":"SMART",
            "start_date":"2020-07-12",
            "password":"Bridges2020",
            "ids":[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
          },
          {
            "name":"BOLD",
            "start_date":"2020-07-11",
            "password":"Bridges2020",
            "ids":[ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ]
          }
        ]
       '
  raise e
  exit 1
end

begin
  file = File.read(ARGV.first)
  json = JSON.parse(file)
  name = ''
  json.each do |group|
    name = group['name']
    password = group['password']
    Admin::Healgroup.create!(name: name, start_date: group['start_date'])
    group['ids'].each do |id|
      username = "bridges#{id}"
      acct = Account.create!(username: username)
      usr = User.create(email: "#{username}@asu.edu", password: password, password_confirmation: password, heal_group_name: name, confirmed_at: Time.now.utc, account: acct, agreement: true)
      usr.approve!
      usr.save!
      group_follows!(usr)
    end
  end
rescue => e
  error!(e)
end
