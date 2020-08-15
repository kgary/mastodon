require 'optparse'
require_relative '../config/environment.rb'


@options = {}
@options[:filePath] = 'data_export'
options_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: ET_user_eai.rb { --all | --group-name:string | --account-id:integer | --username:string }'

  opts.separator ''
  opts.separator 'To filter by group or user, provide either a healgroup id, healgroup name, an account id or a username:'

  opts.on('-a', '--all', 'Find all users in the database') do |a|
    @options[:all] = a
  end

  opts.on('-g', '--group-name healgroup', 'Find all users in a healgroup by name') do |g|
    @options[:group_name] = g
  end

  opts.on('-i', '--account-id id', 'Find account by id') do |i|
    @options[:account_id] = i
  end

  opts.on('-u', '--username username', 'Find account by username') do |u|
    @options[:username] = u
  end

  opts.on('-p', '--pwd path/to/write/directory', 'Where to save the files') do |p|
    @options[:filePath] = p
  end
end

begin
  options_parser.parse!
rescue OptionParser::InvalidOption => e
  puts "\n***************************\n#{e}\n***************************\n\n"
  puts options_parser
  exit 1
end

GROUP = 'private'
# get all account ids

accounts = []
if @options[:all]
  accounts = Account.where("id IN (#{User.select(:account_id).where("moderator = FALSE AND admin = FALSE").to_sql})")
elsif @options[:group_name].present?
  accounts = Account.where("id IN (#{User.select(:account_id).where("moderator = FALSE AND admin = FALSE and heal_group_name = '#{@options[:group_name]}'").to_sql})")
elsif @options[:account_id].present?
  accounts = [Account.find(@options[:account_id])]
elsif @options[:username].present?
  accounts = [Account.find_by(username: @options[:username])]
end

user_cols = %w(id account_id email sign_in_count admin moderator heal_group_name)
user_bonus_cols = %w(posts favourites pinned reports futureSelf SMART Bold IfThen Coping Maybes EngagementScore)

op = 'text ILIKE'
maybe_bridges_query = ''
keywords = %w('%take%5%' '%goal%' '%bold%' '%if%then%' '%coping%' '%smart%' '%future%self%' '%manage%my%emotions%' '%get%some%help%' '%lifestyle%' '%career%' '%community%' '%family%' '%health%' '%friends%')
keywords.each do |keyword|
  maybe_bridges_query << " OR #{op} #{keyword}"
end
maybe_bridges_query = maybe_bridges_query[4..-1]
maybe_bridges_query = "futureself = FALSE AND goal = FALSE and bridges_tag = FALSE AND (#{maybe_bridges_query})"

status_cols = []
status_cols = Status.column_names
status_cols.prepend 'role'
status_cols.prepend 'username'
status_cols.prepend 'user_id'
status_cols.append 'maybe bridges'

accounts.each do |a| #make separate books per user
  p = Axlsx::Package.new
  p.workbook.add_worksheet(name: "#{a.username}") do |sheet|
    sheet.add_row user_cols + user_bonus_cols
    user = []
    user_cols.each do |v|
      user.append(a.user[v])
    end
    user.append(a.statuses.count)
    user.append(a.favourites.count)
    user.append(a.pinned_statuses.count)
    user.append(a.reports.count)
    user.append(a.statuses.where('futureself = true').count) #futureSelf
    user.append(a.statuses.where("bridges_tag = true AND text ILIKE '%SMART%'").count) #SMART
    user.append(a.statuses.where("bridges_tag = true AND text ILIKE '%Bold%'").count) #Bold
    user.append(a.statuses.where("bridges_tag = true AND text ILIKE '%IfThen%'").count) #IfThen
    user.append(a.statuses.where("bridges_tag = true AND text ILIKE '%Coping%'").count) #Coping
    user.append(a.statuses.where(maybe_bridges_query).count) #Maybes
    user.append(a.user.ahoy_events.count) #EngagementEvents
    sheet.add_row user
    sheet.add_row
    sheet.add_row

    user_mods_and_bots_oh_my = User.where("admin = FALSE AND moderator = TRUE AND (heal_group_name = 'Global' OR heal_group_name = '#{a.user.heal_group_name}') OR account_id = #{a.id}")
    accounts = Account.where("id IN (#{user_mods_and_bots_oh_my.select(:account_id).to_sql})")
    statuses = Status.unscoped { Status.where("account_id IN (#{accounts.pluck(:id).join(',')})").order(created_at: :ASC) }

    maybes = statuses.where(maybe_bridges_query)

    sheet.add_row status_cols
    statuses.each do |s|
      if(s.visibility == GROUP || (s.visibility == 'direct' && (s.text.include? "@#{a.username}")))
      account = accounts.find(s.account_id)
      row = s.as_json.values
      row.prepend account.user.admin ? 'admin' : account.user.moderator ? 'moderator' : 'user'
      row.prepend account.username
      row.prepend account.user.id
      if maybes.present?
        row.append maybes.where("id = #{s.id}").present?
      else
        row.append false
      end
      sheet.add_row row
      end
    end
    p.serialize("#{@options[:filePath]}/#{a.username}_EAI.xlsx")
  end
end

