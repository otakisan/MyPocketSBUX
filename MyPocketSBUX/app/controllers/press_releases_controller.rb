class PressReleasesController < ApplicationController
  before_action :set_press_release, only: [:show, :edit, :update, :destroy]

  # GET /press_releases
  # GET /press_releases.json
  def index
    type = params["type"]

    if type == "range" then
      indexbyrange(params["key"], "1", "2147483647")
    else
      fiscal_year = params["fiscal_year"]
      if fiscal_year != nil then
        @press_releases = PressRelease.where('fiscal_year = ?', fiscal_year)
      else
        @press_releases = PressRelease.all
      end
    end
  end

  def indexbyrange(key, frommax, tomax)
    from = (params["from"] || frommax).to_i
    to = (params["to"] || tomax).to_i
    @press_releases = PressRelease.where("#{key} between ? and ?", from, to)
  end

  # GET /press_releases/1
  # GET /press_releases/1.json
  def show
  end

  # GET /press_releases/new
  def new
    @press_release = PressRelease.new
  end

  # GET /press_releases/1/edit
  def edit
  end

  # POST /press_releases
  # POST /press_releases.json
  def create
    @press_release = PressRelease.new(press_release_params)

    respond_to do |format|
      if @press_release.save
        format.html { redirect_to @press_release, notice: 'Press release was successfully created.' }
        format.json { render :show, status: :created, location: @press_release }
      else
        format.html { render :new }
        format.json { render json: @press_release.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /press_releases/1
  # PATCH/PUT /press_releases/1.json
  def update
    respond_to do |format|
      if @press_release.update(press_release_params)
        format.html { redirect_to @press_release, notice: 'Press release was successfully updated.' }
        format.json { render :show, status: :ok, location: @press_release }
      else
        format.html { render :edit }
        format.json { render json: @press_release.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /press_releases/1
  # DELETE /press_releases/1.json
  def destroy
    @press_release.destroy
    respond_to do |format|
      format.html { redirect_to press_releases_url, notice: 'Press release was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_press_release
      @press_release = PressRelease.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def press_release_params
      params.require(:press_release).permit(:fiscal_year, :press_release_sn, :title, :url)
    end
end
