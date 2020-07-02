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
end
