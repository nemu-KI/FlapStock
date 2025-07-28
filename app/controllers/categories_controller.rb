class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = current_user.company.categories.includes(:items)
  end

  def show
  end

  def new
    @category = current_user.company.categories.build
  end

  def create
    @category = current_user.company.categories.build(category_params)

    if @category.save
      redirect_to categories_path, notice: '分類が正常に作成されました。'
    else
      flash.now[:alert] = '分類の作成に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: '分類が正常に更新されました。'
    else
      flash.now[:alert] = '分類の更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    category_name = @category.name

    if @category.destroy
      redirect_to categories_path, notice: "「#{category_name}」が正常に削除されました。"
    else
      redirect_to categories_path, alert: "「#{category_name}」の削除に失敗しました。"
    end
  end

  private

  def set_category
    @category = current_user.company.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end
end
