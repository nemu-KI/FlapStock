# frozen_string_literal: true

# StockMovementsController
class StockMovementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock_movement, only: %i[show edit update destroy]
  before_action :set_item, only: %i[index new create]

  def index
    @q = if @item
           # 物品別の履歴表示
           policy_scope(StockMovement).where(item: @item).includes(:user).ransack(params[:q])
         else
           # 全体の履歴表示
           policy_scope(StockMovement).includes(:item, :user).ransack(params[:q])
         end
    @stock_movements = @q.result(distinct: true).order(created_at: :desc).page(params[:page])
  end

  def show
    authorize @stock_movement
  end

  def new
    @stock_movement = @item.stock_movements.build
    @stock_movement.movement_category = params[:movement_category] if params[:movement_category].present?
    authorize @stock_movement
  end

  def create
    @stock_movement = @item.stock_movements.build(stock_movement_params)
    @stock_movement.user = current_user
    @stock_movement.company = current_user.company

    authorize @stock_movement

    if @stock_movement.save
      redirect_to @item, notice: '入出庫が正常に記録されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @stock_movement
  end

  def update
    authorize @stock_movement

    if @stock_movement.update(stock_movement_params)
      redirect_to @stock_movement, notice: '入出庫記録が正常に更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @stock_movement

    begin
      @stock_movement.destroy
      redirect_to stock_movements_path, notice: '入出庫記録が正常に削除されました。'
    rescue StandardError
      redirect_to @stock_movement, alert: '入出庫記録の削除に失敗しました。'
    end
  end

  private

  def set_stock_movement
    @stock_movement = StockMovement.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to stock_movements_path, alert: '指定された入出庫記録が見つかりません。'
  end

  def set_item
    @item = Item.find(params[:item_id]) if params[:item_id]
  rescue ActiveRecord::RecordNotFound
    redirect_to items_path, alert: '指定された物品が見つかりません。'
  end

  def stock_movement_params
    params.require(:stock_movement).permit(:movement_category, :quantity, :reason, :note)
  end
end
