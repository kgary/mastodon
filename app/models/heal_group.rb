# == Schema Information
#
# Table name: heal_groups
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  start_date :date             default(Tue, 09 Jun 2020)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class HealGroup < ApplicationRecord
end
