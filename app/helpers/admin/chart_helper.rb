# frozen_string_literal: true

module Admin::ChartHelper

  def render_single_line_engagement_chart(ahoy_events)
    @ahoy_events.group_by_day(:time).count
  end

  def render_multi_line_engagement_chart(ahoy_events_all)
    @ahoy_events_passive = { name: 'Passive Events', data: [] }
    @ahoy_events_active = { name: 'Active Events', data: [] }

    @ahoy_events_passive[:data] = @ahoy_events_all.where("properties @> ? OR properties @> ?", '{"action": "show"}', '{"action": "index"}')
    @ahoy_events_active[:data]  = @ahoy_events_all.where("properties @> ? OR properties @> ? OR properties @> ?", '{"action": "create"}', '{"action": "update"}', '{"action": "destroy"}')

    @ahoy_events_passive[:data] = @ahoy_events_passive[:data].group_by_day(:time).count
    @ahoy_events_active[:data] = @ahoy_events_active[:data].group_by_day(:time).count
    @ahoy_events_multi_data = []
    @ahoy_events_multi_data.append(@ahoy_events_passive)
    @ahoy_events_multi_data.append(@ahoy_events_active)
  end
end
