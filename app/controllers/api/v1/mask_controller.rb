module Api
  module V1
    class MaskController < ApiController
      def index
        result = MasksService.call(masks_params)
        if result.success?
          render json: result.payload
        else
          render json: result.error
        end
      end

      private

      def masks_params
        {
          pharmacy_id: params[:pharmacy_id],
          order_key: order_key,
          sort_key: sort_key
        }
      end

      def order_key
        params[:order]&.downcase == 'name' ? 'name' : 'price'
      end

      def sort_key
        params[:sort]&.downcase == 'desc' ? 'desc' : 'asc'
      end
    end
  end
end


