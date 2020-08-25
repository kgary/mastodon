# frozen_string_literal: true
require 'csv'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include Remotable

  class << self
    def update_index(_type_name, *_args, &_block)
      super if Chewy.enabled?
    end
  end

  def boolean_with_default(key, default_value)
    value = attributes[key]

    if value.nil?
      default_value
    else
      value
    end
  end

  def self.to_csv
    ::CSV.generate do |csv|
      csv << column_names
      all.find_each do |model|
        csv << model.attributes.values_at(*column_names)
      end
    end
  end
end
