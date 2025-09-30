# frozen_string_literal: true

# CategoriesController
class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %i[show edit update destroy]

  def index
    @categories = policy_scope(Category).includes(:items)
  end

  def show
    authorize @category
  end

  def new
    @category = current_user.company.categories.build
    authorize @category
  end

  def create
    @category = current_user.company.categories.build(category_params)
    authorize @category

    if @category.save
      redirect_to categories_path, notice: '分類が正常に作成されました。'
    else
      flash.now[:alert] = '分類の作成に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @category
  end

  def update
    authorize @category
    if @category.update(category_params)
      redirect_to categories_path, notice: '分類が正常に更新されました。'
    else
      flash.now[:alert] = '分類の更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @category
    category_name = @category.name

    begin
      if @category.destroy
        redirect_to categories_path, notice: "「#{category_name}」が正常に削除されました。"
      else
        redirect_to categories_path, alert: "「#{category_name}」の削除に失敗しました。"
      end
    rescue ActiveRecord::InvalidForeignKey, ActiveRecord::DeleteRestrictionError
      redirect_to categories_path, alert: "「#{category_name}」は使用中のため削除できません。関連する物品を先に削除してください。"
    end
  end

  private

  def set_category
    # 他社のデータにアクセスしようとした場合も権限エラーとして扱う
    @category = Category.find(params[:id])
    return if @category.company == current_user.company

    raise Pundit::NotAuthorizedError, 'この操作を実行する権限がありません。'
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end
end
