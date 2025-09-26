# frozen_string_literal: true

# DashboardsController
class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @company = current_user.company
    load_dashboard_data
  end


  private

  def load_dashboard_data
    @total_items = @company.items.count
    @recent_movements = load_recent_movements
    load_monthly_statistics
    load_items_by_category
    load_items_by_location
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
end
