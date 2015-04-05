class StoresController < ApplicationController
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  # GET /stores
  # GET /stores.json
  def index
    type = params["type"]

    if type == "range" then
      @stores = indexbyrange(params["key"], "1", "2147483647")
    else
      @stores = Store.all
    end
  end

  def indexbyrange(key, frommax, tomax)
    from = (params["from"] || frommax).to_i
    to = (params["to"] || tomax).to_i
    sortdirection = (params["sortdirection"] || "DESC")
    @stores = Store.where("#{key} between ? and ?", from, to).order("#{key} #{sortdirection}")
  end

  # GET /stores/1
  # GET /stores/1.json
  def show
  end

  # GET /stores/new
  def new
    @store = Store.new
  end

  # GET /stores/1/edit
  def edit
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Store.new(store_params)

    respond_to do |format|
      if @store.save
        format.html { redirect_to @store, notice: 'Store was successfully created.' }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to @store, notice: 'Store was successfully updated.' }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store.destroy
    respond_to do |format|
      format.html { redirect_to stores_url, notice: 'Store was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def store_params
      params.require(:store).permit(:store_id, :name, :address, :phone_number, :holiday, :access, :opening_time_weekday, :closing_time_weekday, :opening_time_saturday, :closing_time_saturday, :opening_time_holiday, :closing_time_holiday, :latitude, :longitude, :notes, :pref_id)
    end
end
