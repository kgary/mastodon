require 'optparse'
require_relative '../config/environment.rb'


@options = {}
@options[:filePath] = 'data_export'

options_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: ET_user_eai.rb --pwd path/to/folder'

  opts.on('-p', '--pwd path/write/directory', 'Where to save the file') do |p|
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

user_cols = %w(id account_id email sign_in_count admin moderator heal_group_name)
users = User.select(user_cols).where('admin = FALSE AND moderator = FALSE AND created_at <> updated_at')
accts = Account.all
user_bonus_cols = %w(posts favourites pinned reports futureSelf SMART Bold IfThen Coping Maybes EngagementScore)

op = 'text ILIKE'
maybe_bridges_query = ''
keywords = %w('%take%5%' '%goal%' '%bold%' '%if%then%' '%coping%' '%smart%' '%future%self%' '%manage%my%emotions%' '%get%some%help%' '%lifestyle%' '%career%' '%community%' '%family%' '%health%' '%friends%')
keywords.each do |keyword|
  maybe_bridges_query << " OR #{op} #{keyword}"
end
maybe_bridges_query = maybe_bridges_query[4..-1]
begin
  check_for_bridges_tag = Status.first.bridges_tag
  maybe_bridges_query = "futureself = FALSE AND goal = FALSE and bridges_tag = FALSE AND (#{maybe_bridges_query})"
rescue
  maybe_bridges_query = "futureself = FALSE AND goal = FALSE AND (#{maybe_bridges_query})"
end

p = Axlsx::Package.new
p.workbook.add_worksheet(name: 'Users') do |sheet|
  sheet.add_row user_cols + user_bonus_cols
  users.each do |u|
    user = []
    user_cols.each do |v|
      user.append(u[v])
    end
    a = accts.find(u.account_id)
    user.append(a.statuses.count)
    user.append(a.favourites.count)
    user.append(a.pinned_statuses.count)
    user.append(a.reports.count)
    user.append(a.statuses.where('futureself = true').count) #futureSelf
    begin
      user.append(a.statuses.where("bridges_tag = true AND text ILIKE '%SMART%'").count) #SMART
      user.append(a.statuses.where("bridges_tag = true AND text ILIKE '%Bold%'").count) #Bold
      user.append(a.statuses.where("bridges_tag = true AND text ILIKE '%IfThen%'").count) #IfThen
      user.append(a.statuses.where("bridges_tag = true AND text ILIKE '%Coping%'").count) #Coping
    rescue # old pilots did not have bridges_tag flag
      user.append('bridges_tag added after conclusion of this pilot')
      user.append('bridges_tag added after conclusion of this pilot')
      user.append('bridges_tag added after conclusion of this pilot')
      user.append('bridges_tag added after conclusion of this pilot')
    end
    user.append(a.statuses.where(maybe_bridges_query).count) #Maybes
    user.append(u.ahoy_events.count) #EngagementEvents
    sheet.add_row user
  end
end

# get participants
users = User.where("admin = FALSE AND moderator = FALSE")

# get the accounts of those users
accounts = Account.where("id IN (#{users.select(:account_id).to_sql})")

status_cols = []
status_cols = Status.column_names
status_cols.prepend 'user_id'
status_cols.append 'maybe bridges'

p.workbook.add_worksheet(name: 'Statuses') do |sheet|
  sheet.add_row status_cols
  accounts.each do |a|
    maybes = a.statuses.where(maybe_bridges_query)
    a.statuses.each do |s|
      row = s.as_json.values
      row.prepend a.user.id
      if maybes.present?
        row.append maybes.where("id = #{s.id}").present?
      else
        row.append false
      end
      sheet.add_row row
    end
  end
end


p.serialize("#{@options[:filePath]}/ET_users_statuses.xlsx")
