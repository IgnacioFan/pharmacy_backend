# == Schema Information
#
# Table name: opening_hours
#
#  id          :bigint           not null, primary key
#  close       :time             not null
#  open        :time             not null
#  weekday     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  pharmacy_id :bigint           not null
#
# Indexes
#
#  index_opening_hours_on_pharmacy_id  (pharmacy_id)
#
# Foreign Keys
#
#  fk_rails_...  (pharmacy_id => pharmacies.id)
#
require 'rails_helper'

RSpec.describe OpeningHour, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
