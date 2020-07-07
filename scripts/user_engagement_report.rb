#!/usr/bin/env ruby
# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby scripts/user_engagement_report.rb id:integer [-v(erbose)]

require 'json'
require 'optparse'
require Dir.pwd + '/config/environment.rb' # TODO: may need to change this to explicitly state production
require_relative '../app/helpers/admin/chart_helper'

include Admin::ChartHelper

@options = {}
@options[:min_date] = DateTime.new(2020, 1, 1).utc
@options[:max_date] = (DateTime.current + 1).utc
options_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: user_engagement_report.rb { --group-id:integer | --group-name:string | --account-id:integer | --username:string } [options]'

  opts.separator ''
  opts.separator 'To filter by group or user, provide either a healgroup id, healgroup name, an account id or a username:'

  opts.on('-d', '--group-id id', 'Find all users in a healgroup by id') do |d|
    @options[:group_id] = d
    @options[:apply_group_filter] = true
  end

  opts.on('-g', '--group-name healgroup', 'Find all users in a healgroup by name') do |g|
    @options[:group_name] = g
    @options[:apply_group_filter] = true
  end

  opts.on('-i', '--account-id id', 'Find account by id') do |i|
    @options[:account_id] = i
    @options[:apply_user_filter] = true
  end

  opts.on('-u', '--username username', 'Find account by username') do |u|
    @options[:username] = u
    @options[:apply_user_filter] = true
  end

  opts.on('-l', '--min-date', "Minimum value for date range: 'YYYY-MM-DD' OR 'YYYY-MM-DD hh:mm:ss +offset' (-7 for MST)") do |l|
    @options[:min_date] = DateTime.parse(l).utc
    pp @options[:min_date]
  end
  opts.on('-m', '--max-date', "Maximum value for date range: 'YYYY-MM-DD' OR 'YYYY-MM-DD hh:mm:ss +offset' (-7 for MST)") do |m|
    @options[:max_date] = DateTime.parse(m).utc
    pp @options[:max_date]
  end

  opts.separator ''
  opts.separator 'Options:'
  opts.on('-b', '--bridges', 'Get Bridges Specific Events') do |b|
    @options[:bridges] = b
  end
  opts.on('-e', '--active', 'Get Active Engagement Events') do |e|
    @options[:active] = e
  end
  opts.on('-p', '--passive', 'Get Passive Engagement Events') do |p|
    @options[:passive] = p
  end
  opts.on('-a', '--all', 'Get all Engagement Events: Active, Passive, and Bridges') do |a|
    @options[:all] = a
  end
  opts.on('-v', '--verbose', 'Run verbosely') do |v|
    @options[:verbose] = v
  end
end

begin
  options_parser.parse!
rescue OptionParser::InvalidOption => e
  puts "\n***************************\n#{e}\n***************************\n\n"
  puts options_parser
  exit 1
end

ch = Admin::ChartHelper

def get_user_data(account_id = nil, username = nil)
  ch = Admin::ChartHelper
  # get meta data
  # get any and all events flagged
  # return as {user_meta_data: {}, data_sets: []}
  user_meta_data = if account_id.present?
                     find_user_data_by_id(account_id)
                   else
                     find_user_data_by_username(username)
                   end
  data_sets = []
  user_events = ahoy_events_for_user(user_meta_data[:user_id])
  if @options[:all] || @options[:active]
    # get active
    active_events = active_events_for_user(user_events, min: @options[:min_date], max: @options[:max_date], verbose: @options[:verbose])
    data_sets.append(active_events)
  end
  if @options[:all] || @options[:passive]
    # get passive
    passive_events = passive_events_for_user(user_events, min: @options[:min_date], max: @options[:max_date], verbose: @options[:verbose])
    data_sets.append(passive_events)
  end
  if @options[:all] || @options[:bridges]
    # get bridges
    bridges_events = bridges_events_for_user(user_events, min: @options[:min_date], max: @options[:max_date], verbose: @options[:verbose])
    data_sets.append(bridges_events)
  end
  { user_meta_data: user_meta_data, data_sets: data_sets }
end

def get_group_data(healgroup)
  user_data = []
  healgroup_name = healgroup.first.present? ? healgroup.first.heal_group_name : 'empty or invalid group'
  healgroup.each do |user|
    data = get_user_data(user.account_id)
    user_data.append(data)
  end
  { healgroup: healgroup_name, user_data: user_data }
end

def write(json)
  File.open('testy.json', 'w') do |f|
    f.write(JSON.pretty_generate(json))
  end
end

response = []
if @options[:apply_group_filter] # get all users in a specific group
  healgroups = [get_heal_group(@options[:group_id], @options[:group_name])]
elsif !@options[:apply_user_filter] # get a specific user
  healgroups = get_heal_groups
else # get data for all users in a healgroup
  user_data = get_user_data(@options[:account_id], @options[:username])
  healgroup = { healgroup: user_data[:user_meta_data][:healgroup], user_data: [user_data] }
  res = response.append(healgroup)
  write(res)
  return
end

healgroups.each do |healgroup|
  data = get_group_data(healgroup)
  response.append(data)
end

res = response
write(res)

