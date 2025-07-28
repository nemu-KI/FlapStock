class LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  def index
    @locations = current_user.company.locations.includes(:items)
  end

  def show
  end

  def new
    @location = current_user.company.locations.build
  end

  def create
    @location = current_user.company.locations.build(location_params)

    if @location.save
      redirect_to locations_path, notice: '保管場所が正常に作成されました。'
    else
      flash.now[:alert] = '保管場所の作成に失敗しました。'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @location.update(location_params)
      redirect_to locations_path, notice: '保管場所が正常に更新されました。'
    else
      flash.now[:alert] = '保管場所の更新に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    location_name = @location.name

    if @location.destroy
      redirect_to locations_path, notice: "「#{location_name}」が正常に削除されました。"
    else
      redirect_to locations_path, alert: "「#{location_name}」の削除に失敗しました。"
    end
  end

  private

  def set_location
    @location = current_user.company.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :description)
  end
end
