module Api
  module V1
    class PharmacyController < ApiController
      def index
        render json: { message: "hello world" }
      end
    end
  end
end


