require 'swagger_helper'

RSpec.describe 'api/v1/pharmacy', type: :request do

  # path '/api/v1/pharmacies' do
  #   before do
  #     create_list(:pharmacy, 2)
  #   end

  #   get('list pharmacies') do
  #     parameter name: :open, in: :query, type: :string, description: 'pharmacy opening time, specify time format \[hh:mm\]'
  #     parameter name: :close, in: :query, type: :string, description: 'pharmacy closing time, specify time format \[hh:mm\]'

  #     response(200, 'return pharmacies') do
  #       let(:open)  { "10:00" }
  #       let(:close) { "18:00" }

  #       schema type: :array,
  #         items: {
  #           properties: {
  #             id: { type: :integer },
  #             name: { type: :string },
  #             cash_balance: { type: :string },
  #             created_at: { type: :string },
  #             updated_at: { type: :string }
  #           }
  #         }
  #       run_test! do |response|
  #         expect(response).to have_http_status(:ok)

  #         pharmacies = JSON.parse(response.body)
  #         expect(pharmacies.size).to eq(2)
  #       end
  #     end
  #   end
  # end

  # before do
    let(:pharmacy) { create(:pharmacy) }
    let(:mask1) { create(:mask, name: 'N95 Mask', color: 'White', num_per_pack: 10) }
    let(:mask2) { create(:mask, name: 'N96 Mask', color: 'Blue', num_per_pack: 20) }
    let(:mask3) { create(:mask, name: 'N97 Mask', color: 'Orange', num_per_pack: 12) }
    let!(:pharmacy_mask1) { create(:pharmacy_mask, pharmacy: pharmacy, mask: mask1, price: 20.00) }
    let!(:pharmacy_mask2) { create(:pharmacy_mask, pharmacy: pharmacy, mask: mask2, price: 15.00) }
    let!(:pharmacy_mask3) { create(:pharmacy_mask, pharmacy: pharmacy, mask: mask3, price: 10.00) }
  # end

  path '/api/v1/pharmacies/masks' do
    parameter name: :num, in: :query, type: :string
    parameter name: :price_range, in: :query, type: :string

    get('list pharmacies with more or less than N mask products within a price range') do
      let(:num)  { 1 }
      let(:price_range) { '15-20' }

      response(200, 'return pharmacies') do
        # schema type: :array,
        #   items: {
        #     properties: {
        #       id: { type: :integer },
        #       name: { type: :string },
        #     }
        #   }
        run_test! do |response|
          expect(response).to have_http_status(:ok)

          pharmacies = JSON.parse(response.body)
          puts pharmacies
          expect(pharmacies.size).to eq(2)
        end
      end
    end
  end
end
