module Api
  module V1
    class PurchaseController < ApiController
      def index
        unless valid_date_range?
          render json: { error: 'Invalid date range: start date must be earlier than end date' }, status: :bad_request and return
        end

        result = TopPurchaseUsersService.call(top_purchase_users_params)
        if result.success?
          render json: result.payload
        else
          render json: result.error
        end
      end

      private

      def valid_date_range?
        puts start_date
        puts end_date
        end_date && (start_date < end_date)
      end

      def start_date
        params[:start_date].presence || 3.months.ago.strftime("%Y-%m-%d")
      end

      def end_date
        params[:end_date].to_s
      end

      def top
        params[:top].presence
      end

      def top_purchase_users_params
        {
          top: top,
          start_date: DateTime.parse(start_date).utc.to_s,
          end_date: end_date.present? ? DateTime.parse(end_date).utc.to_s : nil
        }
      end
    end
  end
end
