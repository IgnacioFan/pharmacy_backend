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
class OpeningDay < ApplicationRecord
end
