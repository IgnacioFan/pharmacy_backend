# == Schema Information
#
# Table name: pharmacies
#
#  id           :bigint           not null, primary key
#  cash_balance :decimal(2, )     not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Pharmacy < ApplicationRecord
end
