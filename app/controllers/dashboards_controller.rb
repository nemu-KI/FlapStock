class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @company = current_user.company

    # 在庫サマリー
    @total_items = @company.items.count

    # 最近の入出庫履歴（最新5件）
    @recent_movements = @company.stock_movements.includes(:item, :user)
                               .order(created_at: :desc)
                               .limit(5)



    # 今月の統計
    @current_month = Date.current.beginning_of_month
    @monthly_inbound_count = @company.stock_movements.inbound
                                    .where(created_at: @current_month..@current_month.end_of_month)
                                    .count
    @monthly_outbound_count = @company.stock_movements.outbound
                                     .where(created_at: @current_month..@current_month.end_of_month)
                                     .count

    # 分類別のアイテム数
    @items_by_category = @company.items.joins(:category)
                               .group('categories.name')
                               .count
                               .sort_by { |_, count| -count }

    # 保管場所別のアイテム数
    @items_by_location = @company.items.joins(:location)
                                .group('locations.name')
                                .count
                                .sort_by { |_, count| -count }
  end
end
