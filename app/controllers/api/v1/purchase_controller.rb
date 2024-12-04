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
          render json: { error: result.error }, status: :bad_request
        end
      end

      def create
        result = CreatePurchaseHistoryService.call(create_purchase_history_params)
        if result.success?
          render json: result.payload, status: :created
        else
          render json: { error: result.error }, status: :bad_request
        end
      end

      private

      def valid_date_range?
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

      def create_purchase_history_params
        params.require(:purchase).permit(:user_id, :pharmacy_mask_id)
      end
    end
  end
end
