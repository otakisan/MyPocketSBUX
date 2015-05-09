class TunesController < ApplicationController
  before_action :set_tune, only: [:show, :edit, :update, :destroy]

  # GET /tunes
  # GET /tunes.json
  def index
    @tunes = Tune.all
  end

  # GET /tunes/1
  # GET /tunes/1.json
  def show
  end

  # GET /tunes/new
  def new
    @tune = Tune.new
  end

  # GET /tunes/1/edit
  def edit
  end

  # POST /tunes
  # POST /tunes.json
  def create
    @tune = Tune.new(tune_params)

    respond_to do |format|
      if @tune.save
        format.html { redirect_to @tune, notice: 'Tune was successfully created.' }
        format.json { render :show, status: :created, location: @tune }
      else
        format.html { render :new }
        format.json { render json: @tune.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tunes/1
  # PATCH/PUT /tunes/1.json
  def update
    respond_to do |format|
      if @tune.update(tune_params)
        format.html { redirect_to @tune, notice: 'Tune was successfully updated.' }
        format.json { render :show, status: :ok, location: @tune }
      else
        format.html { render :edit }
        format.json { render json: @tune.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tunes/1
  # DELETE /tunes/1.json
  def destroy
    @tune.destroy
    respond_to do |format|
      format.html { redirect_to tunes_url, notice: 'Tune was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tune
      @tune = Tune.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tune_params
      params.require(:tune).permit(:wrapper_type, :kind, :artist_id, :collection_id, :track_id, :artist_name, :collection_name, :track_name, :collection_censored_name, :track_censored_name, :artist_view_url, :collection_view_url, :track_view_url, :preview_url, :artwork_url_30, :artwork_url_60, :artwork_url_100, :collection_price, :track_price, :release_date, :collection_explicitness, :track_explicitness, :disc_count, :disc_number, :track_count, :track_number, :track_time_millis, :country, :currency, :primary_genre_name, :radio_station_url)
    end
end
