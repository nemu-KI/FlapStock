# frozen_string_literal: true

# SuppliersController
class SuppliersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_supplier, only: %i[show edit update destroy]
  before_action :check_guest_restrictions, only: %i[create update]

  def index
    @suppliers = policy_scope(Supplier).includes(:items)
  end

  def autocomplete
    query = params[:q].to_s.strip
    limit = params[:limit]&.to_i || 10

    return render json: [] if query.length < 2

    suppliers = policy_scope(Supplier)
                .where('name ILIKE ?', "%#{query}%")
                .limit(limit)
                .pluck(:name, :id)
                .map { |name, id| { text: name, id: id } }

    render json: suppliers
  end

  def show
    authorize @supplier
  end

  def new
    @supplier = current_user.company.suppliers.build
    authorize @supplier
  end

  def create
    @supplier = current_user.company.suppliers.build(supplier_params)
    authorize @supplier

    if @supplier.save
      redirect_to suppliers_path, notice: '発注先が正常に作成されました。'
    else
      flash.now[:alert] = '発注先の作成に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @supplier
  end

  def update
    authorize @supplier
    if @supplier.update(supplier_params)
      redirect_to suppliers_path, notice: '発注先が正常に更新されました。'
    else
      flash.now[:alert] = '発注先の更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @supplier
    supplier_name = @supplier.name

    begin
      if @supplier.destroy
        redirect_to suppliers_path, notice: "「#{supplier_name}」が正常に削除されました。"
      else
        redirect_to suppliers_path, alert: "「#{supplier_name}」の削除に失敗しました。"
      end
    rescue ActiveRecord::InvalidForeignKey, ActiveRecord::DeleteRestrictionError
      redirect_to suppliers_path, alert: "「#{supplier_name}」は使用中のため削除できません。関連する物品を先に削除してください。"
    end
  end

  private

  # ゲストユーザーの制限チェック
  def check_guest_restrictions
    return unless session[:guest_mode]

    # ゲストユーザーのマスターデータ作成制限（1セッションあたり最大5件）
    return unless action_name == 'create'

    guest_suppliers_count = current_user.company.suppliers.where(
      'created_at > ?', session[:guest_session_start]&.to_time || 1.hour.ago
    ).count
    return unless guest_suppliers_count >= 5

    redirect_to suppliers_path, alert: 'お試しモードでは1セッションあたり最大5件まで仕入先を作成できます。'
    nil
  end

  def set_supplier
    # 他社のデータにアクセスしようとした場合も権限エラーとして扱う
    @supplier = Supplier.find(params[:id])
    return if @supplier.company == current_user.company

    raise Pundit::NotAuthorizedError, 'この操作を実行する権限がありません。'
  end

  def supplier_params
    params.require(:supplier).permit(:name, :email, :phone, :address, :contact_person, :note)
  end
end
