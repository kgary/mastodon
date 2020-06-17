#!/usr/bin/env ruby

require Dir.pwd + '/config/environment.rb' # TODO may need to change this to explicitly state production

if ARGV.any? && ARGV.first.match(/\d/)
  @id = ARGV.first
else
  p 'first argument must be an integer for user_id'
  exit(0)
end

# TODO extract to function file
def filter_by_action(user_events, action)
  array = Array.new
  user_events.each do |event|
    array.append(event) if event['properties']['action'] == action
  end
  pp array
end

@user = User.find(@id)

@user_events = @user.ahoy_events.all

filter_by_action(@user_events, ARGV.second || 'create')

