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
require 'rails_helper'

RSpec.describe Pharmacy, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
