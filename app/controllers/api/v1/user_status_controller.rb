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
              'weight_unit' => current_user.weight_unit,
              'weight_precision' => current_user.weight_precision
            }, status: :ok
        else
          render json: { 'current_user_id' => nil, 'weight_unit' => 'gram', 'weight_precision' => 2 }, status: :ok
        end
      end

      def update
        puts params
        update_hash = {}
        #add the relevant things to the update
        if params[:weight_unit]
          update_hash[:weight_unit] = params[:weight_unit]
        end

        if params[:weight_precision]
          update_hash[:weight_precision] = params[:weight_precision]
        end
        
        if current_user.update_attributes update_hash  # if the weight stuff updates...
          render json: nil, status: :ok
        else
          render json: current_user.errors, status: :unprocessable_entity
        end
      end
    end
  end
end