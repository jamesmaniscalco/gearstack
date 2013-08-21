module Api
  module V1
    class UserStatusController < ApplicationController
      # only respond to json requests
      respond_to :json

      #authentication
      before_filter :authenticate_user!, :except => [:status]

      def status
        if user_signed_in?
          render json: {
              'current_user_id' => current_user.id,
              'weight_unit' => current_user.weight_unit
            }, status: :ok
        else
          render json: { 'current_user_id' => nil, 'weight_unit' => 'gram' }, status: :ok
        end
      end

      def update    # for now we're only updating the weight unit
        if current_user.update_attribute :weight_unit, params[:weight_unit]   # if the weight unit updates...
          render json: nil, status: :ok
        else
          render json: current_user.errors, status: :unprocessable_entity
        end
      end
    end
  end
end