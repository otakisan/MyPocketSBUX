class ProductIngredientsController < ApplicationController
  before_action :set_product_ingredient, only: [:show, :edit, :update, :destroy]

  # GET /product_ingredients
  # GET /product_ingredients.json
  def index
    @product_ingredients = ProductIngredient.all
  end

  # GET /product_ingredients/1
  # GET /product_ingredients/1.json
  def show
  end

  # GET /product_ingredients/new
  def new
    @product_ingredient = ProductIngredient.new
  end

  # GET /product_ingredients/1/edit
  def edit
  end

  # POST /product_ingredients
  # POST /product_ingredients.json
  def create
    @product_ingredient = ProductIngredient.new(product_ingredient_params)

    respond_to do |format|
      if @product_ingredient.save
        format.html { redirect_to @product_ingredient, notice: 'Product ingredient was successfully created.' }
        format.json { render :show, status: :created, location: @product_ingredient }
      else
        format.html { render :new }
        format.json { render json: @product_ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_ingredients/1
  # PATCH/PUT /product_ingredients/1.json
  def update
    respond_to do |format|
      if @product_ingredient.update(product_ingredient_params)
        format.html { redirect_to @product_ingredient, notice: 'Product ingredient was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_ingredient }
      else
        format.html { render :edit }
        format.json { render json: @product_ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_ingredients/1
  # DELETE /product_ingredients/1.json
  def destroy
    @product_ingredient.destroy
    respond_to do |format|
      format.html { redirect_to product_ingredients_url, notice: 'Product ingredient was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_ingredient
      @product_ingredient = ProductIngredient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_ingredient_params
      params.require(:product_ingredient).permit(:order_detail_id, :is_custom, :name, :milk_type, :unit_calorie, :unit_price, :quantity, :enabled, :quantity_type, :remarks)
    end
end
