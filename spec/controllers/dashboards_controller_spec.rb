require 'rails_helper'

RSpec.describe DashboardsController, type: :controller do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }
  let(:category) { create(:category, company: company) }
  let(:location) { create(:location, company: company) }
  let(:supplier) { create(:supplier, company: company) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'ダッシュボードが表示される' do
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:company)).to eq(company)
    end

    it '在庫サマリーが正しく計算される' do
      # テストデータを作成
      create(:item, company: company, category: category, location: location, supplier: supplier)
      create(:item, company: company, category: category, location: location, supplier: supplier)

      get :index
      expect(assigns(:total_items)).to eq(2)
    end

    it '最近の入出庫履歴が表示される' do
      # テストデータを作成
      item = create(:item, company: company, category: category, location: location, supplier: supplier)
      movement1 = create(:stock_movement, item: item, user: user, company: company, created_at: 1.day.ago)
      movement2 = create(:stock_movement, item: item, user: user, company: company, created_at: 2.days.ago)
      movement3 = create(:stock_movement, item: item, user: user, company: company, created_at: 3.days.ago)

      get :index
      expect(assigns(:recent_movements)).to include(movement1, movement2, movement3)
      expect(assigns(:recent_movements).count).to eq(3)
    end

    it '今月の統計が正しく計算される' do
      # 今月のデータを作成
      item = create(:item, company: company, category: category, location: location, supplier: supplier)
      create(:stock_movement, item: item, user: user, company: company,
             movement_category: 'inbound', created_at: Date.current)
      create(:stock_movement, item: item, user: user, company: company,
             movement_category: 'outbound', created_at: Date.current)

      get :index
      expect(assigns(:monthly_inbound_count)).to eq(1)
      expect(assigns(:monthly_outbound_count)).to eq(1)
    end

    it '分類別のアイテム数が正しく計算される' do
      # テストデータを作成
      category1 = create(:category, name: 'カテゴリ1', company: company)
      category2 = create(:category, name: 'カテゴリ2', company: company)

      create(:item, company: company, category: category1, location: location, supplier: supplier)
      create(:item, company: company, category: category1, location: location, supplier: supplier)
      create(:item, company: company, category: category2, location: location, supplier: supplier)

      get :index
      expect(assigns(:items_by_category)).to include(['カテゴリ1', 2], ['カテゴリ2', 1])
    end

    it '保管場所別のアイテム数が正しく計算される' do
      # テストデータを作成
      location1 = create(:location, name: '場所1', company: company)
      location2 = create(:location, name: '場所2', company: company)

      create(:item, company: company, category: category, location: location1, supplier: supplier)
      create(:item, company: company, category: category, location: location1, supplier: supplier)
      create(:item, company: company, category: category, location: location2, supplier: supplier)

      get :index
      expect(assigns(:items_by_location)).to include(['場所1', 2], ['場所2', 1])
    end

    it '他社のデータは表示されない' do
      # 他社のデータを作成
      other_company = create(:company)
      other_user = create(:user, company: other_company)
      other_item = create(:item, company: other_company)
      create(:stock_movement, item: other_item, user: other_user, company: other_company)

      get :index
      expect(assigns(:total_items)).to eq(0)
      expect(assigns(:recent_movements)).to be_empty
      expect(assigns(:monthly_inbound_count)).to eq(0)
      expect(assigns(:monthly_outbound_count)).to eq(0)
    end
  end

  describe '認証チェック' do
    context '未ログインの場合' do
      before { sign_out user }

      it 'ログインページにリダイレクトされる' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
