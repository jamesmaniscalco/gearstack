module Api
  module V1
    class GearListsController < ApplicationController
      # only respond to json requests
      respond_to :json

      #filters:
      #authentication
      before_filter :authenticate_user!
      #permissions, etc.
      before_filter :find_list, :only => [:show, :update, :destroy]


      def index
        #@gear_lists = GearList.where(:user_id => current_user.id)
        @gear_lists = current_user.gear_lists
        # render json: @gear_lists
      end

      def show
        # render json: @gear_list
      end

      def create
        @gear_list = GearList.new(params[:gear_list])
        @gear_list.user = current_user  # and set the owner and possessor to be the current user.
        if @gear_list.save
          render json: @gear_list, status: :created, location: @gear_item
        else
          render json: @gear_list.errors, status: :unprocessable_entity
        end
      end

      def update
        if @gear_list.update_attributes(params[:gear_list])
          render json: nil, status: :ok
        else
          render json: @gear_list.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @gear_list.destroy
        render json: nil, status: :ok
      end

      protected

      def find_list
        @gear_list = GearList.find(params[:id])
      end

    end
  end
end