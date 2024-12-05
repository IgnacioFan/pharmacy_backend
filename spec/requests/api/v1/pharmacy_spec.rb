require 'swagger_helper'

RSpec.describe 'api/v1/pharmacy', type: :request do

  path '/api/v1/pharmacies/opening_hours' do

    get('list pharmacies at a specific time and weekday') do
      parameter name: :time, in: :query, type: :string, description: 'opening time (time format \[hh:mm\])'
      parameter name: :weekday, in: :query, type: :integer, description: 'weekday (0: Mon, 1: Thu, 2: Wed, 3: Thur, 4: Fri, 5: Sat, 6: Sun)'
      let(:time) { '08:00' }
      let(:weekday) { 4 }
      let(:successful_payload) do
        [
          { "pharmacy_id" => 1, "pharmacy_name" => "DFW Wellness", "weekdays" => { "Fri" => { "open_hour" => "08:00", "close_hour" => "12:00" }}},
          { "pharmacy_id" => 2, "pharmacy_name" => "Carepoint", "weekdays" => { "Fri" => { "open_hour" => "08:00", "close_hour" => "17:00" }}}
        ]
      end

      response(200, 'ok') do
        before do
          service_result = double('ServiceResult', success?: true, payload: successful_payload)
          allow(OpeningHoursService).to receive(:call).and_return(service_result)
        end

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq(successful_payload)
        end
      end

      response(422, 'unprocessable entity') do
        let(:time) { '08-00' }

        run_test! do
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)).to eq('error' => 'Invalid time (correct format: hh:mm / 24 hours)')
        end
      end

      response(422, 'unprocessable entity') do
        let(:weekday) { 7 }

        run_test! do
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)).to eq('error' => 'Invalid weekday (correct format: (0, 1, 2, 3, 4, 5, 6)')
        end
      end
    end
  end

  path '/api/v1/pharmacies' do

    get('list pharmacies with more or less than N mask products within a price range') do
      parameter name: :num, in: :query, type: :string, description: 'N mask products'
      parameter name: :price_range, in: :query, type: :string, description: 'price range (e.g. 10-15)'
      let(:num)  { 1 }
      let(:price_range) { '15-20' }
      let(:successful_payload) do
        {
          "Higher" => [
            { "pharmacy_name" => "Keystone Pharmacy", "masks" => [ { "name" => "Cotton Kiss (black) (3 per pack)", "price" => "3.8" }] },
            { "pharmacy_name" => "HealthMart", "masks" => [ { "name" => "True Barrier (black) (3 per pack)", "price" => "3.38" }] }
          ],
          "Lower" => []
        }
      end

      response(200, 'ok') do
        before do
          service_result = double('ServiceResult', success?: true, payload: successful_payload)
          allow(PharmaciesService).to receive(:call).and_return(service_result)
        end

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq(successful_payload)
        end
      end

      response(422, 'unprocessable entity') do
        let(:price_range) { '15-10' }

        run_test! do
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)).to eq('error' => 'Invalid price range (left bound should lower than right bound)')
        end
      end
    end
  end
end
