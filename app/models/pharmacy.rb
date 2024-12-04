# == Schema Information
#
# Table name: pharmacies
#
#  id           :bigint           not null, primary key
#  cash_balance :decimal(10, 2)   not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Pharmacy < ApplicationRecord
  has_many :opening_hours, dependent: :destroy
  has_many :pharmacy_masks
  has_many :masks, through: :pharmacy_masks

  validates :name, presence: true
  validates :cash_balance, numericality: { greater_than_or_equal_to: 0 }
end
