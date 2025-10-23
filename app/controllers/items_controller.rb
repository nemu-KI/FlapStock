# frozen_string_literal: true

# ItemsController
class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: %i[show edit update destroy]
  before_action :check_guest_restrictions, only: %i[create update]
  before_action :set_form_data, only: %i[new create edit update]

  def index
    @q = policy_scope(Item).includes(:category, :location, :supplier).ransack(params[:q])
    @items = @q.result(distinct: true)
               .page(params[:page])
               .per(current_user.per_page || Kaminari.config.default_per_page)
  end

  def autocomplete
    return render json: [] if autocomplete_query_too_short?

    items = build_autocomplete_items
    render json: items
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

  # ゲストユーザーの制限チェック
  def check_guest_restrictions
    return unless session[:guest_mode]

    # ゲストユーザーのデータ作成制限（1セッションあたり最大10件）
    return unless action_name == 'create'

    guest_items_count = current_user.company.items.where('created_at > ?',
                                                         session[:guest_session_start]&.to_time || 1.hour.ago).count
    return unless guest_items_count >= 10

    redirect_to items_path, alert: 'お試しモードでは1セッションあたり最大10件まで物品を作成できます。'
    nil
  end

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
    @period = params[:period] || '3months'
    chart_service = ItemChartService.new(@item, @period)
    chart_result = chart_service.prepare_chart_data

    @chart_data = chart_result[:chart_data]
    @min_stock_line = chart_result[:stock_line_data][:min_stock_line]
    @max_stock_line = chart_result[:stock_line_data][:max_stock_line]
    @current_stock = chart_result[:stock_line_data][:current_stock]
  end

  def autocomplete_query_too_short?
    params[:q].to_s.strip.length < 2
  end

  def build_autocomplete_items
    query = params[:q].to_s.strip
    field = validate_autocomplete_field
    limit = params[:limit]&.to_i || 10

    policy_scope(Item)
      .where("#{field} ILIKE ?", "%#{query}%")
      .limit(limit)
      .pluck(field.to_sym, :id)
      .map { |text, id| { text: text, id: id } }
  end

  def validate_autocomplete_field
    field = params[:field].present? ? params[:field] : 'name'
    allowed_fields = %w[name sku]
    allowed_fields.include?(field) ? field : 'name'
  end
end
