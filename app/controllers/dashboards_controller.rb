# frozen_string_literal: true

# DashboardsController
class DashboardsController < ApplicationController
  before_action :authenticate_user!, except: [:root]

  def index
    @company = current_user.company
    load_dashboard_data
  end

  def root
    # ルートページ用のOGPタグを設定
    @page_title = 'FlapStock - 在庫管理システム'
    @page_description = 'FlapStockは、効率的な在庫管理を実現するWebアプリケーションです。物品の入出庫管理、在庫状況の把握、発注先管理などの機能を提供します。'

    # ログイン済みの場合はダッシュボードにリダイレクト
    if user_signed_in?
      redirect_to dashboard_path
    else
      # 未ログインの場合はログイン画面にリダイレクト
      redirect_to new_user_session_path
    end
  end

  private

  def load_dashboard_data
    @total_items = @company.items.count
    @recent_movements = load_recent_movements
    load_monthly_statistics
    load_items_by_category
    load_items_by_location
    load_alert_statistics
  end

  def load_recent_movements
    @company.stock_movements.includes(:item, :user)
            .order(created_at: :desc)
            .limit(5)
  end

  def load_monthly_statistics
    @current_month = Date.current.beginning_of_month
    month_range = @current_month..@current_month.end_of_month

    @monthly_inbound_count = @company.stock_movements.inbound
                                     .where(created_at: month_range)
                                     .count
    @monthly_outbound_count = @company.stock_movements.outbound
                                      .where(created_at: month_range)
                                      .count
  end

  def load_items_by_category
    @items_by_category = @company.items.joins(:category)
                                 .group('categories.name')
                                 .count
                                 .sort_by { |_, count| -count }
  end

  def load_items_by_location
    @items_by_location = @company.items.joins(:location)
                                 .group('locations.name')
                                 .count
                                 .sort_by { |_, count| -count }
  end

  def load_alert_statistics
    @low_stock_count = @company.items.low_stock.count
    @overstock_count = @company.items.overstock.count
    @total_alerts = @low_stock_count + @overstock_count
  end
end
