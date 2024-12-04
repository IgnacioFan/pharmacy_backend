require 'rails_helper'

RSpec.describe TotalPurchaseAmountAndMaskNumsService, type: :service do
  describe '#call' do
    let!(:mask1) { create(:mask, num_per_pack: 10) }
    let!(:mask2) { create(:mask, num_per_pack: 20) }
    let!(:pharmacy_mask1) { create(:pharmacy_mask, mask: mask1) }
    let!(:pharmacy_mask2) { create(:pharmacy_mask, mask: mask2) }
    let!(:purchase1) do
      create(:purchase_history, pharmacy_mask: pharmacy_mask1, transaction_amount: 100, transaction_date: '2023-02-01')
    end
    let!(:purchase2) do
      create(:purchase_history, pharmacy_mask: pharmacy_mask2, transaction_amount: 200, transaction_date: '2023-03-01')
    end
    let(:start_date) { Date.parse('2023-01-01') }
    let(:end_date) { Date.parse('2023-12-31') }
    let(:params) { { start_date: start_date, end_date: end_date } }

    context 'when valid start_date and end_date are provided' do
      it 'returns the total transaction amount and mask numbers within the date range' do
        result = described_class.call(params)

        expect(result.success?).to eq(true)
        expect(result.payload[:total_transaction_amount]).to eq(300)
        expect(result.payload[:total_mask_nums]).to eq(30)
      end
    end

    context 'when only start_date is provided' do
      let(:params) { { start_date: start_date } }

      it 'calculates total amounts from start_date onward' do
        result = described_class.call(params)

        expect(result.success?).to eq(true)
        expect(result.payload[:total_transaction_amount]).to eq(300)
        expect(result.payload[:total_mask_nums]).to eq(30)
      end
    end

    context 'when no records match the date range' do
      let(:params) { { start_date: Date.parse('2025-01-01'), end_date: Date.parse('2025-12-31') } }

      it 'returns zero for both' do
        result = described_class.call(params)

        expect(result.success?).to eq(true)
        expect(result.payload[:total_transaction_amount]).to eq(0)
        expect(result.payload[:total_mask_nums]).to eq(0)
      end
    end
  end
end
