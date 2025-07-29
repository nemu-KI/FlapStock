class SuppliersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_supplier, only: [:show, :edit, :update, :destroy]

  def index
    @suppliers = policy_scope(Supplier).includes(:items)
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
    rescue ActiveRecord::InvalidForeignKey
      redirect_to suppliers_path, alert: "「#{supplier_name}」は使用中のため削除できません。関連する物品を先に削除してください。"
    end
  end

  private

  def set_supplier
    # 他社のデータにアクセスしようとした場合も権限エラーとして扱う
    @supplier = Supplier.find(params[:id])
    unless @supplier.company == current_user.company
      raise Pundit::NotAuthorizedError, "この操作を実行する権限がありません。"
    end
  end

  def supplier_params
    params.require(:supplier).permit(:name, :email, :phone, :address, :contact_person, :note)
  end
end
