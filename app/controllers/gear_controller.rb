class GearController < ApplicationController
  # only respond to json requests
  respond_to :json

  #filters
  before_filter :find_item, :only => [:show, :edit, :update, :destroy]



  # CRUD!

  def index
    @gear_items = GearItem.all

    render json: @gear_items
  end

  def show
    render json: @gear_item
  end
  
  def create
    @gear_item = GearItem.new(params[:gear_item])
    if @gear_item.save
      render json: @gear_item, status: :created, location: @gear_item
    else
      render json: @gear_item.errors, status: :unprocessable_entity
    end
  end

  def update
    if @gear_item.update_attributes(params[:gear_item])
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
end
