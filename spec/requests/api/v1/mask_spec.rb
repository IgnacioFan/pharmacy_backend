require 'swagger_helper'

RSpec.describe 'api/v1/mask', type: :request do

  path '/api/v1/pharmacies/{pharmacy_id}/masks' do

    get('list masks for a given pharmacy') do
      consumes 'application/json'
      parameter name: :pharmacy_id, in: :path, type: :string, description: 'pharmacy id'
      parameter name: :order, in: :query, type: :string, description: 'order by mask name or price'
      parameter name: :sort, in: :query, type: :string, description: 'sort in asc or desc'
      let(:pharmacy_id) { 1 }
      let(:order) { 'price' }
      let(:sort) { 'asc' }
      let(:successful_payload) do
        [
          { "mask_name" => "MaskT", "mask_color" => "green", "mask_price" => 41.86, "num_per_pack" => 10},
          { "mask_name" => "Second Smile", "mask_color" => "black", "mask_price" => 31.98, "num_per_pack" => 10},
          { "mask_name" => "True Barrier", "mask_color" => "green", "mask_price" => 13.7, "num_per_pack" => 3}
        ]
      end

      response(200, 'ok') do
        before do
          service_result = double('ServiceResult', success?: true, payload: successful_payload)
          allow(MasksService).to receive(:call).and_return(service_result)
        end

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq(successful_payload)
        end
      end
    end
  end
end
