module Api
  module V1
    class PharmacyController < ApiController
      def index
        unless valid_price_range?
          render json: { error: 'Invalid price range format. Use "lower-upper".' }, status: :bad_request and return
        end

        result = PharmaciesService.call(pharmacies_params)
        if result.success?
          render json: result.payload
        else
          render json: result.error
        end
      end

      def opening_hours
        result = OpeningHoursService.call(opening_hours_params)
        if result.success?
          render json: result.payload
        else
          render json: result.error
        end
      end

      private

      def valid_price_range?
        params[:price_range] =~ /\d+-\d+/
      end

      def pharmacies_params
        lower_bond, upper_bond = params[:price_range].split('-').map(&:to_i)

        {
          mask_num: params[:num].to_i,
          lower_bond: lower_bond,
          upper_bond: upper_bond
        }
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
