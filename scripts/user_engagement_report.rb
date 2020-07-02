#!/usr/bin/env ruby

#RAILS_ENV=production bundle exec ruby scripts/user_engagement_report.rb id:integer [-v(erbose)]

require 'json'
require 'optparse'
require Dir.pwd + '/config/environment.rb' # TODO may need to change this to explicitly state production
require_relative '../app/helpers/admin/chart_helper'

include Admin::ChartHelper

options = {}
options_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: user_engagement_report.rb < -i:integer | -u:string > [options]'

  opts.separator ''
  opts.separator 'Must provide either an account-id or username:'
  opts.on('-i', '--account-id id', 'Find account by id') do |i|
    options[:account_id] = i
  end

  opts.on('-u', '--username username', 'Find account by username') do |u|
    options[:username] = u
  end

  opts.separator ''
  opts.separator 'Options:'
  opts.on('-b', '--bridges', 'Get Bridges Engagement Events') do |b|
    options[:bridges] = b
  end
  opts.on('-e', '--active', 'Get Active Engagement Events') do |e|
    options[:active] = e
  end
  opts.on('-p', '--passive', 'Get Passive Engagement Events') do |p|
    options[:passive] = p
  end
  opts.on('-a', '--all', 'Get all Engagement Events: Active, Passive, and Bridges') do |a|
    options[:all] = a
  end
  opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
    options[:verbose] = v
  end

end

begin
  options_parser.parse!
rescue OptionParser::InvalidOption => e
  puts "\n***************************\n#{e}\n***************************\n\n"
  puts options_parser
  exit 1
end


if options[:account_id].present? || options[:username].present?
  ch = Admin::ChartHelper
  user_meta_data = options[:account_id].present? ? find_user_data_by_id(options[:account_id]) : find_user_data_by_username(options[:username])
  @ahoy_events_all = Ahoy::Event.where(user_id: user_meta_data[:user_id])
  @ahoy_events_multi_data = {}
  @ahoy_events_multi_data = if options[:verbose]
                              ch.export_multi_line_engagement_chart_verbose(@ahoy_events_all)
                            else
                              ch.export_multi_line_engagement_chart(@ahoy_events_all)
                            end
  pp user_meta_data, data_sets: @ahoy_events_multi_data
  File.open('testy.json', 'w') do |f|
    f.write(JSON.pretty_generate(user_meta_data: user_meta_data, data_sets: @ahoy_events_multi_data.as_json))
  end
else
  puts options_parser.help
  exit(0)
end





