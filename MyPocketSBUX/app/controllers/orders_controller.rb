class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  protect_from_forgery :except => [:create, :update, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    #p order_params[:order_details_attributes]
    #p order_params[:order_details]
    #p order_params[:tax_excluded_total_price]
    #p order_params[:order].store_id
    #p order_params[:order].order_details_attributes
    #p @order.order_details.length

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      #p "test !!"
      #p params[:order_details_attributes]
      #params.require(:order).permit(:store_id, :tax_excluded_total_price, :tax_included_total_price, :remarks, :notes, :order_details_attributes => [:order_id, :product_jan_code, :product_name, :size, :hot_or_iced, :reusable_cup, :ticket, :tax_exclude_total_price, :tax_exclude_custom_price, :total_calorie, :custom_calorie, :remarks])
      params.require(:order).permit(:store_id, :tax_excluded_total_price, :tax_included_total_price, :remarks, :notes, :order_details_attributes => [:order_id, :product_jan_code, :product_name, :size, :hot_or_iced, :reusable_cup, :ticket, :tax_exclude_total_price, :tax_exclude_custom_price, :total_calorie, :custom_calorie, :remarks]).tap do |whitelisted|
    whitelisted[:order_details_attributes] = params[:order_details_attributes]
    end
      #params.require(:order).permit(:store_id, :tax_excluded_total_price, :tax_included_total_price, :remarks, :notes, order_details_attributes: [{:order_id, :product_jan_code, :product_name, :size, :hot_or_iced, :reusable_cup, :ticket, :tax_exclude_total_price, :tax_exclude_custom_price, :total_calorie, :custom_calorie, :remarks}])
    end
end
