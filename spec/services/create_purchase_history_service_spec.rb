require 'rails_helper'

RSpec.describe CreatePurchaseHistoryService, type: :service do
  describe '.call' do
    let(:user) { create(:user, cash_balance: 100.0) }
    let(:pharmacy) { create(:pharmacy, cash_balance: 0.0) }
    let(:mask) { create(:mask, name: 'Surgical Mask', color: 'Blue', num_per_pack: 50) }
    let(:pharmacy_mask) { create(:pharmacy_mask, pharmacy: pharmacy, mask: mask, price: 20.0) }
    let(:params) { { user_id: user.id, pharmacy_mask_id: pharmacy_mask.id } }

    context 'when the purchase is successful' do
      it 'creates a purchase history, adjusts balances, and returns formatted data' do
        result = described_class.call(params)

        expect(result).to be_success
        expect(result.payload[:transaction_id]).to be_present
        expect(result.payload[:user_name]).to eq(user.name)
        expect(result.payload[:pharmacy_name]).to eq(pharmacy.name)
        expect(result.payload[:mask_name]).to eq("#{mask.name} (#{mask.color}) (#{mask.num_per_pack} per pack)")
        expect(result.payload[:transaction_amount]).to eq(pharmacy_mask.price)
        expect(user.reload.cash_balance).to eq(80.0)
        expect(pharmacy.reload.cash_balance).to eq(20.0)
      end
    end

    context 'when the user does not have enough cash balance' do
      let(:user) { create(:user, cash_balance: 10.0) }

      it 'raises an ActiveRecord::RecordInvalid error' do
        result = described_class.call(params)

        expect(result).not_to be_success
        expect(result.error).to eq("Validation failed: Cash balance must be greater than or equal to 0")
        # Ensure balances remain unchanged
        expect(user.reload.cash_balance).to eq(10.0)
        expect(pharmacy.reload.cash_balance).to eq(0.0)
      end
    end

    context 'when the pharmacy mask is not found' do
      let(:params) { { user_id: user.id, pharmacy_mask_id: 9999 } }

      it 'raises an ActiveRecord::RecordNotFound error' do
        result = described_class.call(params)

        expect(result).not_to be_success
        expect(result.error).to eq("Couldn't find PharmacyMask with 'id'=9999")
        # Ensure balances remain unchanged
        expect(user.reload.cash_balance).to eq(100.0)
        expect(pharmacy.reload.cash_balance).to eq(0.0)
      end
    end
  end
end
