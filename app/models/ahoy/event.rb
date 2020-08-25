# == Schema Information
#
# Table name: ahoy_events
#
#  id         :bigint(8)        not null, primary key
#  visit_id   :bigint(8)
#  user_id    :bigint(8)
#  name       :string
#  properties :jsonb
#  time       :datetime
#

class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :user, optional: true

  def self.to_csv
    events = all.as_json
    events.each do |event|
      event.merge!(event["properties"])
      event.delete("properties")
    end
    csv = ::CSV.generate do |csv|
      csv << events.first.keys
      events.each do |hash|
        csv << hash.values
      end
    end
  end
end

#File.open('eventtest.csv', 'w') do |f|
#  f.write(csv)
#end
