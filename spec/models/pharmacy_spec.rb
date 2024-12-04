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
  let(:pharmacy) { build(:pharmacy, attributes) }

  context 'when the name is not present' do
    let(:attributes) { { name: nil, cash_balance: 100.0 } }

    it do
      expect(pharmacy).to_not be_valid
      expect(pharmacy.errors[:name]).to include("can't be blank")
    end
  end

  context 'when the cash_balance is less than 0' do
    let(:attributes) { { name: 'Foo', cash_balance: -1.0 } }

    it do
      expect(pharmacy).to_not be_valid
      expect(pharmacy.errors[:cash_balance]).to include('must be greater than or equal to 0')
    end
  end

  context 'when the cash_balance is 0' do
    let(:attributes) { { name: 'Foo', cash_balance: 0.0 } }

    it {expect(pharmacy).to be_valid }
  end
end
