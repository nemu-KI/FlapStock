# frozen_string_literal: true

# 物品のチャートデータ生成サービス
class ItemChartService
  def initialize(item, period = '3months')
    @item = item
    @period = period
  end

  def prepare_chart_data
    start_date = calculate_start_date
    movements = fetch_movements_for_period(start_date)
    initial_stock = calculate_initial_stock(movements)
    chart_data = build_stock_movements_data(start_date, movements, initial_stock)
    stock_line_data = set_stock_line_data

    {
      chart_data: chart_data,
      stock_line_data: stock_line_data,
      period: @period
    }
  end

  private

  def calculate_start_date
    case @period
    when '1month'
      1.month.ago
    when '3months', nil
      3.months.ago
    when '6months'
      6.months.ago
    when '1year'
      1.year.ago
    end
  end

  def fetch_movements_for_period(start_date)
    @item.stock_movements
         .where('created_at >= ?', start_date)
         .order(:created_at)
  end

  def calculate_initial_stock(movements)
    initial_stock = @item.stock_quantity || 0
    movements.each do |movement|
      quantity = movement.quantity_change.present? ? movement.quantity_change : movement.quantity
      quantity ||= 0

      case movement.movement_category
      when 'inbound'
        initial_stock -= quantity
      when 'outbound'
        initial_stock += quantity
      when 'adjustment'
        initial_stock = quantity
      end
    end
    initial_stock
  end

  def build_stock_movements_data(start_date, movements, initial_stock)
    date_range = (start_date.to_date..Date.current).to_a
    display_interval = calculate_display_interval
    stock_movements = {}
    current_stock = initial_stock

    date_range.each_with_index do |date, index|
      next unless (index % display_interval).zero? || date == date_range.last

      day_movements = movements.select { |m| m.created_at.to_date == date }
      current_stock = apply_day_movements(day_movements, current_stock)
      stock_movements[date] = current_stock
    end

    stock_movements
  end

  def calculate_display_interval
    case @period
    when '1month'
      1
    when '3months', nil
      3
    when '6months'
      7
    when '1year'
      14
    end
  end

  def apply_day_movements(day_movements, current_stock)
    day_movements.each do |movement|
      quantity = movement.quantity_change.present? ? movement.quantity_change : movement.quantity
      quantity ||= 0

      case movement.movement_category
      when 'inbound'
        current_stock += quantity
      when 'outbound'
        current_stock -= quantity
      when 'adjustment'
        current_stock = quantity
      end
    end
    current_stock
  end

  def set_stock_line_data
    {
      min_stock_line: @item.min_stock,
      max_stock_line: @item.max_stock,
      current_stock: @item.stock_quantity
    }
  end
end
