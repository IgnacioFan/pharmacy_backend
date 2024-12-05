require 'swagger_helper'

RSpec.describe 'api/v1/search', type: :request do

  path '/api/v1/search' do

    get('list relevant search result and ranked by keyword') do
      consumes 'application/json'
      parameter name: :keyword, in: :query, type: :string, description: 'search keyword'
      let(:keyword) { 'blue' }
      let(:successful_payload) do
        [
          { "name" => "Cotton Kiss (blue) (10 per pack)", "mask_id" =>39},
          { "name" => "Cotton Kiss (blue) (3 per pack)", "mask_id" => 24},
          { "name" => "Cotton Kiss (blue) (6 per pack)", "mask_id" => 27}
        ]
      end

      response(200, 'ok') do
        before do
          service_result = double('ServiceResult', success?: true, payload: successful_payload)
          allow(SearchPharmaciesAndMasksService).to receive(:call).and_return(service_result)
        end

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq(successful_payload)
        end
      end

      response(422, 'unprocessable entity') do
        let(:keyword) {}

        run_test! do
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)).to eq('error' => 'Keyword is required')
        end
      end
    end
  end
end
