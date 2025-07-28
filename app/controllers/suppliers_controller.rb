class SuppliersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_supplier, only: [:show, :edit, :update, :destroy]

  def index
    @suppliers = current_user.company.suppliers.includes(:items)
  end

  def show
  end

  def new
    @supplier = current_user.company.suppliers.build
  end

  def create
    @supplier = current_user.company.suppliers.build(supplier_params)

    if @supplier.save
      redirect_to suppliers_path, notice: '発注先が正常に作成されました。'
    else
      flash.now[:alert] = '発注先の作成に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @supplier.update(supplier_params)
      redirect_to suppliers_path, notice: '発注先が正常に更新されました。'
    else
      flash.now[:alert] = '発注先の更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    supplier_name = @supplier.name

    if @supplier.destroy
      redirect_to suppliers_path, notice: "「#{supplier_name}」が正常に削除されました。"
    else
      redirect_to suppliers_path, alert: "「#{supplier_name}」の削除に失敗しました。"
    end
  end

  private

  def set_supplier
    @supplier = current_user.company.suppliers.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:name, :email, :phone, :address, :contact_person, :note)
  end
end
