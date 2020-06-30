#!/usr/bin/env ruby

#RAILS_ENV=production bundle exec ruby scripts/user_engagement_report.rb id:integer [-v(erbose)]

require 'json'
require Dir.pwd + '/config/environment.rb' # TODO may need to change this to explicitly state production
require_relative '../app/helpers/admin/chart_helper'

include Admin::ChartHelper

if ARGV.any? && ARGV.first.match(/\d/)
  ch = Admin::ChartHelper
  @id = ARGV.first
  @ahoy_events_all = Ahoy::Event.where(user_id: User.where(account_id: @id))
  @ahoy_events_multi_data = {}
  @ahoy_events_multi_data = if ARGV.second.eql? '-v'
                              ch.export_multi_line_engagement_chart_verbose(@ahoy_events_all)
                            else
                              ch.export_multi_line_engagement_chart(@ahoy_events_all)
                            end
  pp json: { account_id: @id, data_sets: @ahoy_events_multi_data }
  File.open('testy.json', 'w') do |f|
    f.write(JSON.pretty_generate(json: { account_id: @id, data_sets: @ahoy_events_multi_data.as_json }))
  end
else
  p 'first argument must be an integer for user_id'
  exit(0)
end





