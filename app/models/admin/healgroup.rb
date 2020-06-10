# == Schema Information
#
# Table name: admin_healgroups
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  start_date :date             default(Wed, 10 Jun 2020), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Admin::Healgroup < ApplicationRecord

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
