module Api
  module V1
    class PharmacyController < ApiController
      def index
        unless valid_price_range?
          render json: { error: 'Invalid price range (left bound should lower than right bound)' }, status: :bad_request and return
        end

        result = PharmaciesService.call(pharmacies_params)
        if result.success?
          render json: result.payload
        else
          render json: result.error, status: :bad_request
        end
      end

      def opening_hours
        result = OpeningHoursService.call(opening_hours_params)
        if result.success?
          render json: result.payload
        else
          render json: result.error, status: :bad_request
        end
      end

      private

      def valid_price_range?
        params[:price_range] =~ /\d+-\d+/ && price_range[0] < price_range[1]
      end

      def pharmacies_params
        {
          mask_num: params[:num].to_i,
          lower_bond: price_range[0],
          upper_bond: price_range[1]
        }
      end

      def price_range
        @price_range = params[:price_range].split('-').map(&:to_i)
      end

      def opening_hours_params
        {
          open: params[:open],
          close: params[:close],
          weekday: params[:weekday]
        }
      end
    end
  end
end
