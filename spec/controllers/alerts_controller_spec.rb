# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertsController, type: :controller do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }
  let(:category) { create(:category, company: company) }
  let(:location) { create(:location, company: company) }
  let(:supplier) { create(:supplier, company: company) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it '正常にレスポンスを返す' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'アラート統計をロードする' do
      create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 5,
                    min_stock: 10)
      create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 25,
                    max_stock: 20)
      create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 15,
                    min_stock: 10, max_stock: 20)

      get :index
      expect(assigns(:total_items)).to eq(3)
      expect(assigns(:items_with_alerts)).to eq(3)
      expect(assigns(:low_stock_count)).to eq(1)
      expect(assigns(:overstock_count)).to eq(1)
    end
  end

  describe 'GET #stock' do
    before do
      create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 5,
                    min_stock: 10)
      create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 25,
                    max_stock: 20)
      create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 15,
                    min_stock: 10, max_stock: 20)
    end

    context 'type=allの場合' do
      it '全アラート物品を表示する' do
        get :stock, params: { type: 'all' }
        expect(response).to have_http_status(:success)
        expect(assigns(:items).count).to eq(2) # 在庫不足1件 + 在庫過剰1件
      end
    end

    context 'type=low_stockの場合' do
      it '在庫不足物品のみを表示する' do
        get :stock, params: { type: 'low_stock' }
        expect(response).to have_http_status(:success)
        expect(assigns(:items).count).to eq(1)
        expect(assigns(:items).first.stock_alert_status).to eq('low_stock')
      end
    end

    context 'type=overstockの場合' do
      it '在庫過剰物品のみを表示する' do
        get :stock, params: { type: 'overstock' }
        expect(response).to have_http_status(:success)
        expect(assigns(:items).count).to eq(1)
        expect(assigns(:items).first.stock_alert_status).to eq('overstock')
      end
    end

    context '検索機能' do
      it '物品名で検索できる' do
        get :stock, params: { type: 'all', q: { name_cont: 'テスト' } }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe '認証' do
    it 'ログインしていない場合はリダイレクトする' do
      sign_out user
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
