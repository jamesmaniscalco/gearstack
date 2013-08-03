module Api
  module V1
    class UserStatusController < ApplicationController
      # only respond to json requests
      respond_to :json

      def status
        if user_signed_in?
          render json: { 'current_user_id' => current_user.id }, status: :ok
        else
          render json: { 'current_user_id' => nil }, status: :ok
        end
      end
    end
  end
end