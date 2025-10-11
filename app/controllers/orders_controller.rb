# frozen_string_literal: true

# 発注履歴管理コントローラー
class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: %i[show update destroy]

  # GET /orders
  # 発注履歴一覧
  def index
    @q = current_user.company.orders.ransack(params[:q])
    @orders = @q.result
                .includes(:supplier, :user, order_items: :item)
                .recent
                .page(params[:page])
  end

  # GET /orders/:id
  # 発注詳細
  def show
    # @orderは set_order で設定済み
  end

  # PATCH /orders/:id
  # 発注ステータス更新
  def update
    if @order.update(order_params)
      redirect_to @order, notice: '発注情報を更新しました'
    else
      render :show, alert: '更新に失敗しました'
    end
  end

  # DELETE /orders/:id
  # 発注削除
  def destroy
    @order.destroy!
    redirect_to orders_path, notice: '発注履歴を削除しました'
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to @order, alert: "削除に失敗しました: #{e.message}"
  end

  private

  def set_order
    @order = current_user.company.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status, :notes)
  end
end
