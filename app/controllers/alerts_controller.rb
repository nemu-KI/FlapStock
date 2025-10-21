# frozen_string_literal: true

# AlertsController
class AlertsController < ApplicationController
  before_action :authenticate_user!

  def index
    @company = current_user.company
    load_alert_statistics
  end

  def stock
    @company = current_user.company
    @alert_type = params[:type] || 'all'

    load_stock_alerts
  end

  private

  def load_alert_statistics
    @total_items = @company.items.count
    @items_with_alerts = @company.items.with_stock_alerts.count
    @low_stock_count = @company.items.low_stock.count
    @overstock_count = @company.items.overstock.count
    @alert_items = load_alert_items
  end

  def load_alert_items
    low_stock_ids = @company.items.low_stock.pluck(:id)
    overstock_ids = @company.items.overstock.pluck(:id)
    all_alert_ids = (low_stock_ids + overstock_ids).uniq
    @company.items.where(id: all_alert_ids)
  end

  def load_stock_alerts
    @items = select_alert_items
    apply_search_and_pagination
  end

  def select_alert_items
    case @alert_type
    when 'low_stock'
      @company.items.low_stock.includes(:category, :location, :supplier)
    when 'overstock'
      @company.items.overstock.includes(:category, :location, :supplier)
    else
      load_alert_items.includes(:category, :location, :supplier)
    end
  end

  def apply_search_and_pagination
    @q = @items.ransack(params[:q])
    @items = @q.result.order(:name)
               .page(params[:page])
               .per(current_user.per_page || Kaminari.config.default_per_page)
  end
end
