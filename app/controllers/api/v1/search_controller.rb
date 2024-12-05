module Api
  module V1
    class SearchController < ApiController
      def index
        if keyword.blank?
          render json: { error: 'Keyword is required' }, status: :unprocessable_entity and return
        end

        result = SearchPharmaciesAndMasksService.call(keyword)
        if result.success?
          render json: result.payload
        else
          render json: result.error, status: :bad_request
        end
      end

      private

      def keyword
        @keyword = params[:keyword]&.strip
      end
    end
  end
end
