require 'swagger_helper'

RSpec.describe 'api/v1/purchase', type: :request do

  path '/api/v1/purchases' do

    get('list top purchase users') do
      consumes 'application/json'
      parameter name: :top, in: :query, type: :integer, description: 'the top N purchasing users'
      parameter name: :start_date, in: :query, type: :string, description: 'the start date of the purchase transaction'
      parameter name: :end_date, in: :query, type: :string, description: 'the end date of the purchase transaction'

      let(:top) { 2 }
      let(:start_date) { '2021-01-04' }
      let(:end_date) { '2021-01-26' }
      let(:successful_payload) do
        [
          { "user_id" => 1, "user_name" => "Foo", "total_transaction_amount" => 150.00 },
          { "user_id" => 2, "user_name" => "Bar", "total_transaction_amount" => 100.10 }
        ]
      end

      response(200, 'ok') do
        before do
          service_result = double('ServiceResult', success?: true, payload: successful_payload)
          allow(TopPurchaseUsersService).to receive(:call).and_return(service_result)
        end

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq(successful_payload)
        end
      end

      response(422, 'unprocessable entity') do
        let(:end_date) { '2021-01-01' }

        run_test! do
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)).to eq('error' => 'Invalid date range: start date must be earlier than end date')
        end
      end
    end

    post('create user purchase history') do
      consumes 'application/json'
      parameter name: :purchase, in: :body,
        schema: {
          type: :object,
          properties: {
            user_id: { type: :integer },
            pharmacy_mask_id: { type: :integer }
          },
          required: [ 'user_id', 'pharmacy_mask_id' ]
        }

      let(:purchase) { { purchase: { user_id: user_id, pharmacy_mask_id: pharmacy_mask_id } } }
      let(:user_id) { 1 }
      let(:pharmacy_mask_id) { 10 }

      response(201, 'created') do
        before do
          service_result = double('ServiceResult', success?: true, payload: { transaction_id: 123 })
          allow(CreatePurchaseHistoryService).to receive(:call).and_return(service_result)
        end

        run_test! do
          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)).to eq('transaction_id' => 123)
        end
      end

      response(400, 'bad request') do
        before do
          service_result = double('ServiceResult', success?: false, error: 'Invalid purchase data')
          allow(CreatePurchaseHistoryService).to receive(:call).and_return(service_result)
        end

        run_test! do
          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq('error' => 'Invalid purchase data')
        end
      end
    end
  end

  path '/api/v1/purchases/report' do

    get('total purchase amount and number of masks within a date range') do
      consumes 'application/json'
      parameter name: :start_date, in: :query, type: :string, description: 'the start date of the purchase transaction'
      parameter name: :end_date, in: :query, type: :string, description: 'the end date of the purchase transaction'
      let(:start_date) { '2021-01-04' }
      let(:end_date) { '2021-01-26' }
      let(:successful_payload) do
        {
          "total_transaction_amount" => "100",
          "total_mask_nums" => 10
        }
      end

      response(200, 'ok') do
        before do
          service_result = double('ServiceResult', success?: true, payload: successful_payload)
          allow(TotalPurchaseAmountAndMaskNumsService).to receive(:call).and_return(service_result)
        end

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq(successful_payload)
        end
      end
    end
  end
end
