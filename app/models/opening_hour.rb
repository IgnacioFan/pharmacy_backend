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
class OpeningHour < ApplicationRecord
  WEEKDAYS = {
    "mon"  => 0,
    "tue"  => 1,
    "wed"  => 2,
    "thur" => 3,
    "fri"  => 4,
    "sat"  => 5,
    "sun"  => 6
  }

  belongs_to :pharmacy
end
