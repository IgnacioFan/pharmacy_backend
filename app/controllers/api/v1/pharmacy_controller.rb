module Api
  module V1
    class PharmacyController < ApiController
      def index
        unless valid_price_range?
          render json: { error: 'Invalid price range (left bound should lower than right bound)' }, status: :unprocessable_entity and return
        end

        result = PharmaciesService.call(pharmacies_params)
        if result.success?
          render json: result.payload
        else
          render json: result.error, status: :bad_request
        end
      end

      def opening_hours
        unless valid_opening_time?
          render json: { error: 'Invalid time (correct format: hh:mm / 24 hours)' }, status: :unprocessable_entity and return
        end

        unless valid_weekday?
          render json: { error: 'Invalid weekday (correct format: (0, 1, 2, 3, 4, 5, 6)' }, status: :unprocessable_entity and return
        end

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

      def valid_opening_time?
        return valid_time?(opening_time) if opening_time.present?
        true
      end

      def valid_weekday?
        return weekday.is_a?(Integer) && weekday >= 0 && weekday <= 6 if weekday.present?
        true
      end

      def valid_time?(str)
        Time.strptime(str, "%H:%M").present? rescue false
      end

      def opening_time
        params[:time].presence
      end

      def weekday
        params[:weekday]&.presence&.to_i
      end

      def opening_hours_params
        {
          time: opening_time,
          weekday: weekday
        }
      end
    end
  end
end
