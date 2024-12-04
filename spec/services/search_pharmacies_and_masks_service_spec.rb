require 'rails_helper'

RSpec.describe SearchPharmaciesAndMasksService, type: :service do
  describe '#call' do
    let(:keyword) { 'Test' }

    context 'when there are matching pharmacies and masks' do
      let!(:pharmacy1) { create(:pharmacy, name: 'Test Pharmacy 1') }
      let!(:pharmacy2) { create(:pharmacy, name: 'Another Pharmacy') }
      let!(:mask1) { create(:mask, name: 'Test Mask', color: 'Blue', num_per_pack: 20) }
      let!(:mask2) { create(:mask, name: 'Another Mask', color: 'Red', num_per_pack: 10) }

      it 'returns ranked results including pharmacies and masks' do
        service = SearchPharmaciesAndMasksService.new(keyword)
        result = service.call

        expect(result.success?).to be true
        expect(result.payload).to include(
          { name: 'Test Pharmacy 1', pharmacy_id: pharmacy1.id },
          { name: 'Test Mask (Blue) (20 per pack)', mask_id: mask1.id }
        )
        expect(result.payload).not_to include(
          { name: 'Another Pharmacy', pharmacy_id: pharmacy2.id },
          { name: 'Another Mask (Red) (10 per pack)', mask_id: mask2.id }
        )
      end
    end

    context 'when there are no matching pharmacies or masks' do
      it 'returns an empty array' do
        service = SearchPharmaciesAndMasksService.new(keyword)
        result = service.call

        expect(result.success?).to be true
        expect(result.payload).to eq([])
      end
    end
  end
end
