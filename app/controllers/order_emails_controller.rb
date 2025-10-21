# frozen_string_literal: true

# 発注メール作成コントローラー
class OrderEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_items, only: %i[new]

  # GET /order_emails/select_items
  # サイドバーから物品を選択
  def select_items
    @items = current_user.company.items
                         .includes(:supplier, :category, :location)
                         .order(:name)
    @q = @items.ransack(params[:q])
    @items = @q.result
               .page(params[:page])
               .per(current_user.per_page || Kaminari.config.default_per_page)
  end

  # GET /order_emails/new?item_ids[]=1
  # フォーム入力画面
  def new
    @order_emails = build_order_emails_by_supplier
  end

  # POST /order_emails/preview
  # プレビュー画面
  def preview
    @order_emails = build_order_emails_from_params
    @items = load_items_for_validation

    # バリデーション
    # rubocop:disable Lint/NonLocalExitFromIterator
    @order_emails.each do |order_email|
      next if order_email.valid?

      # エラーメッセージを収集して表示
      error_messages = order_email.errors.full_messages.join('<br>')
      flash.now[:alert] = error_messages.html_safe
      render :new
      return
    end
    # rubocop:enable Lint/NonLocalExitFromIterator

    # プレビュー画面に入った時点で、前回の記録済みフラグをクリア
    session[:order_recorded] = nil
  end

  # POST /order_emails
  # 発注記録とmailto:リンク生成
  def create
    @order_emails = build_order_emails_from_params
    @saved_orders = []

    # 「発注を記録する」にチェックが入っており、かつ未記録の場合のみ記録
    if params[:save_order] == '1' && !session[:order_recorded]
      @order_emails.each do |order_email|
        order = save_order_from_email(order_email)
        @saved_orders << order if order&.persisted?
      end

      if @saved_orders.any?
        flash.now[:notice] = "#{@saved_orders.size}件の発注を記録しました"
        session[:order_recorded] = true
      else
        flash.now[:alert] = '発注の記録に失敗しました。発注数量など必須項目を確認してください。'
      end
    elsif session[:order_recorded]
      flash.now[:info] = 'この発注は既に記録済みです'
    end

    render :preview
  end

  private

  # 選択された物品を読み込み
  def load_items
    item_ids = params[:item_ids] || []
    @items = current_user.company.items
                         .includes(:supplier)
                         .where(id: item_ids)

    return unless @items.empty?

    redirect_to select_items_order_emails_path, alert: '物品が選択されていません'
  end

  # バリデーション用に物品を読み込み（エラー時のフォーム再表示用）
  def load_items_for_validation
    return [] unless params[:order_emails]

    item_ids = []
    params[:order_emails].each_value do |order_email_params|
      next unless order_email_params[:items_attributes]

      order_email_params[:items_attributes].each_value do |item_params|
        item_ids << item_params[:item_id]
      end
    end

    current_user.company.items.where(id: item_ids.compact.uniq).includes(:supplier)
  end

  # 発注先ごとにOrderEmailオブジェクトを作成
  def build_order_emails_by_supplier
    @items.group_by(&:supplier).map do |supplier, items|
      OrderEmail.new(
        supplier: supplier,
        items: items,
        user: current_user
      )
    end
  end

  # パラメータからOrderEmailオブジェクトを作成
  def build_order_emails_from_params
    return [] unless params[:order_emails]

    params[:order_emails].values.map do |order_email_params|
      build_order_email_from_params(order_email_params)
    end
  end

  # 個別のOrderEmailオブジェクトを作成
  def build_order_email_from_params(order_email_params)
    supplier = Supplier.find(order_email_params[:supplier_id])
    items_data = build_items_data(order_email_params[:items_attributes])

    OrderEmail.new(
      supplier: supplier,
      items_data: items_data,
      user: current_user
    )
  end

  # 物品データを構築
  def build_items_data(items_attributes)
    return [] unless items_attributes

    items_attributes.values.map do |item_params|
      item = Item.find(item_params[:item_id])
      {
        item: item,
        quantity: item_params[:quantity],
        delivery_date: item_params[:delivery_date],
        notes: item_params[:notes]
      }
    end
  end

  # OrderEmailから発注レコードを作成
  def save_order_from_email(order_email)
    Order.create!(
      company: current_user.company,
      supplier: order_email.supplier,
      user: current_user,
      status: 'sent', # メールクライアントを開いたので送信済みとする
      order_date: Date.current
    ) do |order|
      order_email.items_data.each do |item_data|
        order.order_items.build(
          item: item_data[:item],
          quantity: item_data[:quantity],
          expected_delivery_date: item_data[:delivery_date],
          notes: item_data[:notes]
        )
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to save order: #{e.message}"
    nil
  end
end
