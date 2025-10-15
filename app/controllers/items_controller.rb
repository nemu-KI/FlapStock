# frozen_string_literal: true

# ItemsController
class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: %i[show edit update destroy]
  before_action :set_form_data, only: %i[new create edit update]

  def index
    @q = policy_scope(Item).includes(:category, :location, :supplier).ransack(params[:q])
    @items = @q.result(distinct: true).page(params[:page])
  end

  def show
    authorize @item
    prepare_chart_data
  end

  def new
    @item = current_user.company.items.build
    authorize @item
  end

  def create
    @item = current_user.company.items.build(item_params)
    authorize @item

    if @item.save
      redirect_to items_path, notice: '物品が正常に作成されました。'
    else
      flash.now[:alert] = '物品の作成に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @item
  end

  def update
    authorize @item
    if @item.update(item_params)
      redirect_to @item, notice: '物品が正常に更新されました。'
    else
      flash.now[:alert] = '物品の更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @item
    item_name = @item.name

    if @item.destroy
      redirect_to items_path, notice: "「#{item_name}」が正常に削除されました。"
    else
      redirect_to items_path, alert: "「#{item_name}」の削除に失敗しました。"
    end
  end

  private

  def set_item
    # 他社のデータにアクセスしようとした場合も権限エラーとして扱う
    @item = Item.find(params[:id])
    return if @item.company == current_user.company

    raise Pundit::NotAuthorizedError, 'この操作を実行する権限がありません。'
  end

  def set_form_data
    @categories = current_user.company.categories
    @locations = current_user.company.locations
    @suppliers = current_user.company.suppliers
  end

  def item_params
    params.require(:item).permit(:name, :stock_quantity, :unit, :category_id, :location_id, :supplier_id, :description,
                                 :sku, :image_url, :min_stock, :max_stock, :image)
  end

  def prepare_chart_data
    # 期間の設定（デフォルトは過去3ヶ月）
    @period = params[:period] || '3months'
    start_date = case @period
                 when '1month'
                   1.month.ago
                 when '3months'
                   3.months.ago
                 when '6months'
                   6.months.ago
                 when '1year'
                   1.year.ago
                 else
                   3.months.ago
                 end

    # 在庫推移データの準備（累積在庫数を計算）
    movements = @item.stock_movements
                     .where('created_at >= ?', start_date)
                     .order(:created_at)

    # 期間開始時点の在庫数を計算
    # 現在の在庫数から期間内の移動を差し引いて、期間開始時点の在庫数を求める
    initial_stock = @item.stock_quantity || 0

    # 期間内の移動を逆算して初期在庫を計算
    movements.each do |movement|
      quantity = movement.quantity_change.present? ? movement.quantity_change : movement.quantity
      quantity = quantity || 0

      # 移動種類に応じて初期在庫を調整（逆算）
      case movement.movement_category
      when 'inbound'
        initial_stock -= quantity  # 入庫分を差し引く（過去に戻る）
      when 'outbound'
        initial_stock += quantity  # 出庫分を戻す（過去に戻る）
      when 'adjustment'
        # 調整の場合は、その時点での在庫数に設定
        initial_stock = quantity
      end
    end

    # 期間の開始日と終了日を設定
    end_date = Date.current
    date_range = (start_date.to_date..end_date).to_a

    # 日別の累積在庫数を計算（連続した日付で）
    stock_movements = {}
    current_stock = initial_stock

    # 期間に応じてデータ表示間隔を調整
    display_interval = case @period
                      when '1month'
                        1  # 1ヶ月は毎日表示
                      when '3months'
                        3  # 3ヶ月は3日間隔
                      when '6months'
                        7  # 6ヶ月は週間隔
                      when '1year'
                        14 # 1年は2週間隔
                      else
                        1
                      end

    # 各日付に対して在庫数を計算
    date_range.each_with_index do |date, index|
      # 表示間隔に応じてデータを間引く
      next unless index % display_interval == 0 || date == date_range.last

      # その日の在庫移動を取得
      day_movements = movements.select { |m| m.created_at.to_date == date }

      # その日の移動を適用
      day_movements.each do |movement|
        quantity = movement.quantity_change.present? ? movement.quantity_change : movement.quantity
        quantity = quantity || 0

        # 移動種類に応じて在庫数を更新
        case movement.movement_category
        when 'inbound'
          current_stock += quantity  # 入庫で在庫増加
        when 'outbound'
          current_stock -= quantity  # 出庫で在庫減少
        when 'adjustment'
          current_stock = quantity   # 調整で在庫数を設定値に
        end
      end

      # その日の在庫数を記録（移動がない日も含む）
      stock_movements[date] = current_stock
    end

    # 在庫下限・上限ラインのデータ
    @min_stock_line = @item.min_stock
    @max_stock_line = @item.max_stock

    # 現在の在庫数を取得
    @current_stock = @item.stock_quantity

    # グラフ用データの準備（在庫推移のみ）
    @chart_data = stock_movements

    # 在庫下限・上限ラインのデータ（別途管理）
    @min_stock_line = @item.min_stock
    @max_stock_line = @item.max_stock
  end
end
