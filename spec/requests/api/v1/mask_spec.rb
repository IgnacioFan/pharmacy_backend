require 'swagger_helper'

RSpec.describe 'api/v1/mask', type: :request do

  let(:pharmacy) { create(:pharmacy) }
  let(:mask1) { create(:mask, name: 'N95 Mask', color: 'White', num_per_pack: 10) }
  let(:mask2) { create(:mask, name: 'N96 Mask', color: 'Blue', num_per_pack: 20) }
  let!(:pharmacy_mask1) { create(:pharmacy_mask, pharmacy: pharmacy, mask: mask1, price: 15.00) }
  let!(:pharmacy_mask2) { create(:pharmacy_mask, pharmacy: pharmacy, mask: mask2, price: 12.00) }

  path '/api/v1/pharmacies/{pharmacy_id}/masks' do
    parameter name: :pharmacy_id, in: :path, type: :string, description: 'pharmacy id'
    parameter name: :order, in: :query, type: :string, description: 'order by mask name or price'
    parameter name: :sort, in: :query, type: :string, description: 'sort in asc or desc'

    get('list masks for a given pharmacy') do
      let(:order) { 'price' }
      let(:sort) { 'asc' }

      response(200, 'ok') do
        schema type: :array,
          items: {
            properties: {
              id: { type: :integer },
              name: { type: :string },
              color: { type: :string },
              num_per_pack: { type: :integer },
              price: { type: :decimal },
            }
          }

        let(:pharmacy_id) { pharmacy.id }

        run_test! do |response|
          expect(response).to have_http_status(:ok)

          parsed_response = JSON.parse(response.body)
          expect(parsed_response.size).to eq(2)
          expect(parsed_response.first).to include(
            "mask_name" => "N96 Mask",
            "mask_color" => "Blue",
            "mask_price" => 12.0,
            "num_per_pack" => 20
          )
          expect(parsed_response.last).to include(
            "mask_name" => "N95 Mask",
            "mask_color" => "White",
            "mask_price" => 15.0,
            "num_per_pack" => 10
          )
        end
      end

      # response '200', 'ok' do
      #   let(:pharmacy_id) { -1 }
      #   run_test! do |response|
      #     expect(response).to have_http_status(:ok)
      #     parsed_response = JSON.parse(response.body)
      #     puts parsed_response
      #     expect(parsed_response).to eq([])
      #   end
      # end
    end
  end
end
