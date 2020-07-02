#!/usr/bin/env ruby
# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby scripts/user_engagement_report.rb id:integer [-v(erbose)]

require 'json'
require 'optparse'
require Dir.pwd + '/config/environment.rb' # TODO: may need to change this to explicitly state production
require_relative '../app/helpers/admin/chart_helper'

include Admin::ChartHelper

@options = {}
options_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: user_engagement_report.rb < --group-id:integer | --group-name:string | --account-id:integer | --username:string > [options]'

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

  opts.separator ''
  opts.separator 'Options:'
  opts.on('-b', '--bridges', 'Get Bridges Engagement Events') do |b|
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
  opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
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

# if filtered?
#  if options[:account_id].present? || options[:username].present?
#    user_meta_data = options[:account_id].present? ? find_user_data_by_id(options[:account_id]) : find_user_data_by_username(options[:username])
#    @ahoy_events_all = Ahoy::Event.where(user_id: user_meta_data[:user_id])
#    @ahoy_events_multi_data = {}
#    @ahoy_events_multi_data = if options[:verbose]
#                                ch.export_multi_line_engagement_chart_verbose(@ahoy_events_all)
#                              else
#                                ch.export_multi_line_engagement_chart(@ahoy_events_all)
#                              end
#    pp user_meta_data, data_sets: @ahoy_events_multi_data
#    File.open('testy.json', 'w') do |f|
#      f.write(JSON.pretty_generate(user_meta_data: user_meta_data, data_sets: @ahoy_events_multi_data.as_json))
#    end
#  else
#    puts options_parser.help
#    exit(0)
#  end
# end
#

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
  if @options[:all] || @options[:active]
    # get active
    active_events = [] # TODO('get active events')
    data_sets.append(active_events)
  end
  if @options[:all] || @options[:passive]
    # get passive
    passive_events = [] # TODO('get passive events')
    data_sets.append(passive_events)
  end
  if @options[:all] || @options[:bridges]
    # get bridges
    bridges_events = [] # TODO('get bridges events')
    data_sets.append(bridges_events)
  end
  # TODO remove and update filters
  @ahoy_events_all = Ahoy::Event.where(user_id: user_meta_data[:user_id])
  @ahoy_events_multi_data = {}
  @ahoy_events_multi_data = if @options[:verbose]
                              ch.export_multi_line_engagement_chart_verbose(@ahoy_events_all)
                            else
                              ch.export_multi_line_engagement_chart(@ahoy_events_all)
                            end
  { user_meta_data: user_meta_data, data_sets: @ahoy_events_multi_data.as_json }
end

def get_group_data(healgroup)
  user_data = []
  healgroup.each do |user|
    data = get_user_data(user.account_id)
    user_data.append(data)
  end
  { healgroup: healgroup.first.heal_group_name, user_data: user_data }
end

def write(json)
  File.open('testy.json', 'w') do |f|
      f.write(JSON.pretty_generate(json))
  end
end
response = []
if @options[:apply_group_filter] # get all users in a specific group
  healgroups = get_heal_group(@options[:group_id], @options[:group_name])
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
# response = []
#
# if not filtered, find all group names (DISTINCT from users), or let healgroups be a single healgroup
#   :healgroups
#   grab all users per group or grab specific user if option is set
#     :healgroupx = { healgroupx: []}
#     per user in group
#       get meta data
#         meta_data = meta_data_by_id()
#         data_sets = []
#       if active events || all
#         get all active events
#         data_sets.push(active_events)
#       if passive events || all
#         get all passive events
#         data_sets.push(passive_events)
#       if bridges events || all
#         get all bridges events
#         data_sets.push(bridges_events)
#       healgroupx[:healgroupx].push({user_meta_data: user_meta_data, data_sets: []})
