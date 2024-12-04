require 'rails_helper'

RSpec.describe MasksService, type: :service do
  describe '#call' do
    let(:pharmacy) { create(:pharmacy) }
    let!(:mask1) { create(:mask, name: 'Test Mask A', color: 'Red', num_per_pack: 20) }
    let!(:mask2) { create(:mask, name: 'Test Mask B', color: 'Blue', num_per_pack: 10) }
    let!(:pharmacy_mask1) { create(:pharmacy_mask, mask: mask1, pharmacy: pharmacy, price: 15.0) }
    let!(:pharmacy_mask2) { create(:pharmacy_mask, mask: mask2, pharmacy: pharmacy, price: 10.0) }
    let!(:other_pharmacy_mask) { create(:pharmacy_mask, mask: mask1, price: 20.0) }

    let(:params) { { pharmacy_id: pharmacy.id, order_key: 'name', sort_key: 'asc' } }

    context 'when pharmacy_id is provided' do
      it 'returns formatted masks ordered by name' do
        service = MasksService.new(params)
        result = service.call

        expect(result.success?).to be true
        expect(result.payload).to eq([
          {
            mask_name: 'Test Mask A',
            mask_color: 'Red',
            mask_price: 15.0,
            num_per_pack: 20
          },
          {
            mask_name: 'Test Mask B',
            mask_color: 'Blue',
            mask_price: 10.0,
            num_per_pack: 10
          }
        ])
      end
    end

    context 'when order_key is price and sort_key is desc' do
      let(:params) { { pharmacy_id: pharmacy.id, order_key: 'price', sort_key: 'desc' } }

      it 'returns formatted masks ordered by price descending' do
        service = MasksService.new(params)
        result = service.call

        expect(result.success?).to be true
        expect(result.payload).to eq([
          {
            mask_name: 'Test Mask A',
            mask_color: 'Red',
            mask_price: 15.0,
            num_per_pack: 20
          },
          {
            mask_name: 'Test Mask B',
            mask_color: 'Blue',
            mask_price: 10.0,
            num_per_pack: 10
          }
        ])
      end
    end

    context 'when no masks are found for the pharmacy' do
      it 'returns an empty array' do
        params[:pharmacy_id] = -1

        service = MasksService.new(params)
        result = service.call

        expect(result.success?).to be true
        expect(result.payload).to eq([])
      end
    end
  end
end
