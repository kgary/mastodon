# frozen_string_literal: true

module Admin::ChartHelper

  def render_single_line_engagement_chart(ahoy_events)
    @ahoy_events.group_by_day(:time).count
  end

  def render_multi_line_engagement_chart(ahoy_events_all)
    @ahoy_events_passive = { name: 'Passive Events', data: [] }
    @ahoy_events_active = { name: 'Active Events', data: [] }
    @ahoy_events_bridges = { name: 'Bridges Events', data: [] }
    @ahoy_events_human_intervention = { name: 'Human Intervention', data: [] }
    @ahoy_events_ai_intervention = { name: 'AI Intervention', data: [] }
    #@ahoy_events_human_intervention = { name: 'Human Intervention', data: { 'Tue, 16 Jun 2020' => 1 }} # TODO pull from Admin::Intervention when created
    #@ahoy_events_ai_intervention = { name: 'AI Intervention', data: { 'Tue, 14 Jun 2020' => 1 }}       # TODO pull from Admin::Intervention when created

    @ahoy_events_passive[:data]    = ahoy_events_all.where('properties @> ? OR properties @> ? OR properties @> ?', '{"action": "show"}', '{"action": "index"}', '{"action": "context"}')
    @ahoy_events_active[:data]     = ahoy_events_all.where('properties @> ? OR properties @> ? OR properties @> ? AND NOT properties @> ?', '{"action": "create"}', '{"action": "update"}', '{"action": "destroy"}', '{"bridges": true}')
    @ahoy_events_bridges[:data]  = ahoy_events_all.where('properties @> ?', '{"bridges": true}')

    @ahoy_events_passive[:data] = @ahoy_events_passive[:data].group_by_day(:time).count
    @ahoy_events_active[:data] = @ahoy_events_active[:data].group_by_day(:time).count
    @ahoy_events_bridges[:data] = @ahoy_events_bridges[:data].group_by_day(:time).count

    @ahoy_events_multi_data = []
    @ahoy_events_multi_data.append(@ahoy_events_human_intervention)
    @ahoy_events_multi_data.append(@ahoy_events_ai_intervention)
    @ahoy_events_multi_data.append(@ahoy_events_passive)
    @ahoy_events_multi_data.append(@ahoy_events_active)
    @ahoy_events_multi_data.append(@ahoy_events_bridges)
    @ahoy_events_multi_data
  end

  def render_multi_line_engagement_chart_verbose(ahoy_events_all)
    @ahoy_events_passive = { name: 'Passive Events', data: [] }
    @ahoy_events_active = { name: 'Active Events', data: [] }
    @ahoy_events_bridges = { name: 'Bridges Events', data: [] }
    @ahoy_events_human_intervention = { name: 'Human Intervention', data: [] }
    @ahoy_events_ai_intervention = { name: 'AI Intervention', data: [] }
    #@ahoy_events_human_intervention = { name: 'Human Intervention', data: { 'Tue, 16 Jun 2020' => 1 }} # TODO pull from Admin::Intervention when created
    #@ahoy_events_ai_intervention = { name: 'AI Intervention', data: { 'Tue, 14 Jun 2020' => 1 }}       # TODO pull from Admin::Intervention when created

    @ahoy_events_passive[:data]    = ahoy_events_all.where('properties @> ? OR properties @> ? OR properties @> ?', '{"action": "show"}', '{"action": "index"}', '{"action": "context"}').select(:user_id, :name, :properties, :time).group(:user_id, :time, :name, :properties).order(:user_id, time: :desc)
    @ahoy_events_active[:data]     = ahoy_events_all.where('properties @> ? OR properties @> ? OR properties @> ? AND NOT properties @> ?', '{"action": "create"}', '{"action": "update"}', '{"action": "destroy"}', '{"bridges": true}').select(:user_id, :name, :properties, :time).group(:user_id, :time, :name, :properties).order(:user_id, time: :desc)
    @ahoy_events_bridges[:data]    = ahoy_events_all.where('properties @> ?', '{"bridges": true}').select(:user_id, :name, :properties, :time).group(:user_id, :time, :name, :properties).order(:user_id, time: :desc)

    @ahoy_events_multi_data = []
    @ahoy_events_multi_data.append(@ahoy_events_human_intervention)
    @ahoy_events_multi_data.append(@ahoy_events_ai_intervention)
    @ahoy_events_multi_data.append(@ahoy_events_passive)
    @ahoy_events_multi_data.append(@ahoy_events_active)
    @ahoy_events_multi_data.append(@ahoy_events_bridges)
    @ahoy_events_multi_data
  end

  def export_multi_line_engagement_chart(ahoy_events_all)
    render_multi_line_engagement_chart(ahoy_events_all)
  end

  def export_multi_line_engagement_chart_verbose(ahoy_events_all)
    render_multi_line_engagement_chart_verbose(ahoy_events_all)
  end

  def find_user_data_by_id(account_id)
    user_meta_data(Account.find(account_id))
  end

  def find_user_data_by_username(username)
    account = Account.find_by(username: username)
    raise ActiveRecord::RecordNotFound, "Couldn't find Account with 'username'='#{username}''" if account.nil?
    user_meta_data(account)
  end

  def user_meta_data(account)
    @user_meta_data = { user_id: account.user.id,
                        account_id: account.id,
                        username: account.username,
                        healgroup: account.user.heal_group_name}
    pp @user_meta_data
  end

  def get_heal_groups
    healgroups = Admin::Healgroup.all
    response = []
    healgroups.each do |healgroup|
      response.append(get_heal_group(healgroup.id))
    end
    response
  end

  def get_heal_group(id = nil, name = nil)
    if id.present?
      healgroup = Admin::Healgroup.find(id)
      User.where("heal_group_name = '#{healgroup.name}'")
    else
      User.where("heal_group_name = '#{name}'")
    end
  end

  def TODO(feature)
    raise "IMPLEMENT #{feature}"
  end
  
  def ahoy_events_for_user(user_id)
    Ahoy::Event.where(user_id: user_id)
  end
  
  def active_events_for_user(user_events, verbose)
    active_events = user_events.where('properties @> ? OR properties @> ? OR properties @> ? AND NOT properties @> ?',
                                      '{"action": "create"}', '{"action": "update"}', '{"action": "destroy"}',
                                      '{"bridges": true}')
    active_events = if !verbose
                      active_events.group_by_day(:time).count
                    else
                       active_events.select(:user_id, :name, :properties, :time)
                                    .group(:user_id, :time, :name, :properties)
                                    .order(:user_id, time: :desc)
                    end
    { name: 'Active Events', data: active_events.as_json }
  end

  def passive_events_for_user(user_events, verbose)
    passive_events = user_events.where('properties @> ? OR properties @> ? OR properties @> ?',
                                       '{"action": "show"}', '{"action": "index"}', '{"action": "context"}')
    passive_events = if !verbose
                       passive_events.group_by_day(:time).count
                    else
                      passive_events.select(:user_id, :name, :properties, :time)
                                    .group(:user_id, :time, :name, :properties)
                                    .order(:user_id, time: :desc)
                    end
    { name: 'Passive Events', data: passive_events.as_json }
  end

  def bridges_events_for_user(user_events, verbose)
    bridges_events = user_events.where('properties @> ?', '{"bridges": true}')
    bridges_events = if !verbose
                       bridges_events.group_by_day(:time).count
                     else
                       bridges_events.select(:user_id, :name, :properties, :time)
                           .group(:user_id, :time, :name, :properties)
                           .order(:user_id, time: :desc)
                     end
    { name: 'Bridges Events', data: bridges_events.as_json }
  end
end
