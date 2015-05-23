class TastingLogsController < ApplicationController
  before_action :set_tasting_log, only: [:show, :edit, :update, :destroy]
  protect_from_forgery :except => [:create, :update, :destroy]

  # GET /tasting_logs
  # GET /tasting_logs.json
  def index
    @tasting_logs = TastingLog.all
  end

  # GET /tasting_logs/1
  # GET /tasting_logs/1.json
  def show
  end

  # GET /tasting_logs/new
  def new
    @tasting_log = TastingLog.new
  end

  # GET /tasting_logs/1/edit
  def edit
  end

  # POST /tasting_logs
  # POST /tasting_logs.json
  def create
    @tasting_log = TastingLog.new(tasting_log_params)

    respond_to do |format|
      if @tasting_log.save
        format.html { redirect_to @tasting_log, notice: 'Tasting log was successfully created.' }
        format.json { render :show, status: :created, location: @tasting_log }
      else
        format.html { render :new }
        format.json { render json: @tasting_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasting_logs/1
  # PATCH/PUT /tasting_logs/1.json
  def update
    respond_to do |format|
      if @tasting_log.update(tasting_log_params)
        format.html { redirect_to @tasting_log, notice: 'Tasting log was successfully updated.' }
        format.json { render :show, status: :ok, location: @tasting_log }
      else
        format.html { render :edit }
        format.json { render json: @tasting_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasting_logs/1
  # DELETE /tasting_logs/1.json
  def destroy
    @tasting_log.destroy
    respond_to do |format|
      format.html { redirect_to tasting_logs_url, notice: 'Tasting log was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tasting_log
      @tasting_log = TastingLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tasting_log_params
      params.require(:tasting_log).permit(:title, :tag, :tasting_at, :detail, :store_id, :order_id)
    end
end
