require 'rails_helper'

RSpec.describe PharmaciesService, type: :service do
  describe '#call' do
    let(:pharmacy1) { create(:pharmacy, name: 'Pharmacy A') }
    let(:pharmacy2) { create(:pharmacy, name: 'Pharmacy B') }

    let(:mask1) { create(:mask, name: 'Mask A', color: 'Red', num_per_pack: 20) }
    let(:mask2) { create(:mask, name: 'Mask B', color: 'Blue', num_per_pack: 10) }
    let(:mask3) { create(:mask, name: 'Mask C', color: 'Green', num_per_pack: 30) }

    let!(:pharmacy_mask1) { create(:pharmacy_mask, pharmacy: pharmacy1, mask: mask1, price: 15.0) }
    let!(:pharmacy_mask2) { create(:pharmacy_mask, pharmacy: pharmacy1, mask: mask2, price: 25.0) }
    let!(:pharmacy_mask3) { create(:pharmacy_mask, pharmacy: pharmacy2, mask: mask3, price: 20.0) }

    let(:params) { { mask_num: 2, lower_bond: 10, upper_bond: 30 } }

    context 'when pharmacies meet the mask number threshold' do
      it 'categorizes pharmacies into Higher and Lower groups' do
        service = PharmaciesService.new(params)
        result = service.call

        expect(result.success?).to be true
        expect(result.payload[:Higher]).to eq([
          {
            pharmacy_name: 'Pharmacy A',
            masks: [
              { name: 'Mask A (Red) (20 per pack)', price: 15.0 },
              { name: 'Mask B (Blue) (10 per pack)', price: 25.0 }
            ]
          }
        ])
        expect(result.payload[:Lower]).to eq([
          {
            pharmacy_name: 'Pharmacy B',
            masks: [
              { name: 'Mask C (Green) (30 per pack)', price: 20.0 }
            ]
          }
        ])
      end
    end

    context 'when a pharmacy has no masks within the price range' do
      it 'returns an empty result for that pharmacy' do
        params[:lower_bond] = 50
        service = PharmaciesService.new(params)
        result = service.call

        expect(result.success?).to be true
        expect(result.payload[:Higher]).to eq([])
        expect(result.payload[:Lower]).to eq([])
      end
    end
  end
end
