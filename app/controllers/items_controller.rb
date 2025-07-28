class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_form_data, only: [:new, :create, :edit, :update]

  def index
    @items = current_user.company.items.includes(:category, :location, :supplier)
  end

  def show
  end

  def new
    @item = current_user.company.items.build
  end

  def create
    @item = current_user.company.items.build(item_params)

    if @item.save
      redirect_to items_path, notice: '物品が正常に作成されました。'
    else
      flash.now[:alert] = '物品の作成に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: '物品が正常に更新されました。'
    else
      flash.now[:alert] = '物品の更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    item_name = @item.name

    if @item.destroy
      redirect_to items_path, notice: "「#{item_name}」が正常に削除されました。"
    else
      redirect_to items_path, alert: "「#{item_name}」の削除に失敗しました。"
    end
  end

  private

  def set_item
    @item = current_user.company.items.find(params[:id])
  end

  def set_form_data
    @categories = current_user.company.categories
    @locations = current_user.company.locations
    @suppliers = current_user.company.suppliers
  end

  def item_params
    params.require(:item).permit(:name, :stock_quantity, :unit, :category_id, :location_id, :supplier_id, :description, :sku, :image_url, :min_stock, :max_stock, :image)
  end
end
