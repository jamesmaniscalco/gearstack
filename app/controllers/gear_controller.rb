
class GearController < ApplicationController
  #filters
  before_filter :find_item, :only => [:show, :edit, :update, :destroy]



  # CRUD!

  def index
    @gear_items = GearItem.all

    respond_to do |format|
      format.html
      format.json { render json: @gear_items }
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @gear_item }
    end
  end
  
  def create
    @gear_item = GearItem.new(params[:gear_item])
    respond_to do |format|
      if @gear_item.save
        format.json { render json: @gear_item, status: :created, location: @gear_item }
      else
        format.json { render json: @gear_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @gear_item.update_attributes(params[:gear_item])
        format.json { render json: nil, status: :ok }
      else
        format.json { render json: @gear_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @gear_item.destroy
    
    respond_to do |format|
      format.json { render json: nil, status: :ok }
    end
  end


  protected

  def find_item
    @gear_item = GearItem.find(params[:id])
  end
end
