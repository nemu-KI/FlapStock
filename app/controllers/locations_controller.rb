class LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  def index
    @locations = policy_scope(Location).includes(:items)
  end

  def show
    authorize @location
  end

  def new
    @location = current_user.company.locations.build
    authorize @location
  end

  def create
    @location = current_user.company.locations.build(location_params)
    authorize @location

    if @location.save
      redirect_to locations_path, notice: '保管場所が正常に作成されました。'
    else
      flash.now[:alert] = '保管場所の作成に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @location
  end

  def update
    authorize @location
    if @location.update(location_params)
      redirect_to locations_path, notice: '保管場所が正常に更新されました。'
    else
      flash.now[:alert] = '保管場所の更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @location
    location_name = @location.name

    begin
      if @location.destroy
        redirect_to locations_path, notice: "「#{location_name}」が正常に削除されました。"
      else
        redirect_to locations_path, alert: "「#{location_name}」の削除に失敗しました。"
      end
    rescue ActiveRecord::InvalidForeignKey
      redirect_to locations_path, alert: "「#{location_name}」は使用中のため削除できません。関連する物品を先に削除してください。"
    end
  end

  private

  def set_location
    # 他社のデータにアクセスしようとした場合も権限エラーとして扱う
    @location = Location.find(params[:id])
    unless @location.company == current_user.company
      raise Pundit::NotAuthorizedError, "この操作を実行する権限がありません。"
    end
  end

  def location_params
    params.require(:location).permit(:name, :description)
  end
end
