# == Schema Information
#
# Table name: opening_days
#
#  id           :bigint           not null, primary key
#  close        :time             not null
#  date_of_week :integer          not null
#  open         :time             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  pharmacy_id  :bigint
#
# Indexes
#
#  index_opening_days_on_pharmacy_id  (pharmacy_id)
#
require 'rails_helper'

RSpec.describe OpeningDay, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
