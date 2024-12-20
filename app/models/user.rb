# == Schema Information
#
# Table name: users
#
#  id           :bigint           not null, primary key
#  cash_balance :decimal(10, 2)   not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class User < ApplicationRecord
  has_many :purchase_histories
  has_many :pharmacy_masks, through: :purchase_histories

  validates :name, presence: true
  validates :cash_balance, numericality: { greater_than_or_equal_to: 0 }
end
