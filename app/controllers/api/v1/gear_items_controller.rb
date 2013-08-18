module Api
  module V1
    class GearItemsController < ApplicationController
      # only respond to json requests
      respond_to :json

      #filters:
      #authentication
      before_filter :authenticate_user!
      #permissions, etc
      before_filter :find_item, :only => [:show, :update, :destroy]
      before_filter :user_owns_or_possesses_item, :only => [:show, :update]
      before_filter :user_owns_and_possesses_item, :only => [:destroy]



      # CRUD!

      def index
        @gear_items = GearItem.all_for_user(current_user)
        # render json: @gear_items
      end

      def show
        # render json: @gear_item
      end
      
      def create
        @gear_item = GearItem.new(params[:gear_item])
        #@gear_item = GearItem.new(params)
        @gear_item.status = 'checkedin'  # set the status to be checked in by default
        @gear_item.owner = current_user  # and set the owner and possessor to be the current user.
        @gear_item.possessor = current_user

        # get the gear list information, if it's there
        @gear_item.gear_lists = []
        if params[:gear_lists]
          params[:gear_lists].each do |list|
            @gear_item.gear_lists << GearList.find(list[:id])
          end
        end

        if @gear_item.save
          render 'api/v1/gear_items/show', status: :created, location: @gear_item
        else
          render json: @gear_item.errors, status: :unprocessable_entity
        end
      end

      def update
        # first, assign the attributes (without saving)
        @gear_item.assign_attributes(params[:gear_item])

        # # and get the gear lists too
        @gear_item.gear_lists = []
        if params[:gear_lists]
          params[:gear_lists].each do |list|
            @gear_item.gear_lists << GearList.find(list[:id])
          end
        end


        # check that the user has permissions to do the update:

        # if they're changing the status, check that they possess it
        if @gear_item.status_changed? and @gear_item.possessor != current_user
          permissions_error and return
        end

        # if they're changing anything else, check that they own it.  this is sloppy, make it better
        if (@gear_item.name_changed? or @gear_item.description_changed? or @gear_item.weight_changed?) and @gear_item.owner != current_user
          permissions_error and return
        end

        # OK, made it this far.  Try and save it.
        if @gear_item.save()
          render json: nil, status: :ok
        else
          render json: @gear_item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @gear_item.destroy
        render json: nil, status: :ok
      end


      protected

      def find_item
        @gear_item = GearItem.find(params[:id])
      end

      def permissions_error
        render json: {'error' => 'You are not authorized to make that request.'}, status: :unauthorized
      end

      def user_owns_or_possesses_item
        if @gear_item.owner != current_user and @gear_item.possessor != current_user
          permissions_error and return
        end
      end

      def user_owns_and_possesses_item
        if @gear_item.owner != current_user or @gear_item.possessor != current_user
          permissions_error and return
        end
      end
    end
  end
end