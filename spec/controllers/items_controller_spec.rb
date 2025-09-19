require 'rails_helper'

RSpec.describe ItemsController, type: :controller do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }
  let(:category) { create(:category, company: company) }
  let(:location) { create(:location, company: company) }
  let(:supplier) { create(:supplier, company: company) }
  let(:item) { create(:item, company: company, category: category, location: location, supplier: supplier) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it '商品一覧が表示される' do
      # テストデータを作成
      create(:item, company: company, category: category, location: location, supplier: supplier)
      
      get :index
      expect(response).to have_http_status(:success)
      expect(assigns(:items)).to be_present
    end

    it '検索機能が動作する' do
      item1 = create(:item, name: 'テスト商品1', company: company)
      item2 = create(:item, name: 'サンプル商品2', company: company)
      
      get :index, params: { q: { name_cont: 'テスト' } }
      expect(response).to have_http_status(:success)
      expect(assigns(:items)).to include(item1)
      expect(assigns(:items)).not_to include(item2)
    end
  end

  describe 'GET #show' do
    it '商品詳細が表示される' do
      get :show, params: { id: item.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:item)).to eq(item)
    end

    it '他社の商品にアクセスすると権限エラーになる' do
      other_company = create(:company)
      other_category = create(:category, company: other_company)
      other_location = create(:location, company: other_company)
      other_supplier = create(:supplier, company: other_company)
      other_item = create(:item, company: other_company, category: other_category, location: other_location, supplier: other_supplier)
      
      # パラメータを設定してset_itemメソッドをテスト
      controller.params[:id] = other_item.id
      expect {
        controller.send(:set_item)
      }.to raise_error(Pundit::NotAuthorizedError, "この操作を実行する権限がありません。")
    end
  end

  describe 'GET #new' do
    it '新規商品作成ページが表示される' do
      get :new
      expect(response).to have_http_status(:success)
      expect(assigns(:item)).to be_a_new(Item)
      expect(assigns(:categories)).to eq(company.categories)
      expect(assigns(:locations)).to eq(company.locations)
      expect(assigns(:suppliers)).to eq(company.suppliers)
    end
  end

  describe 'POST #create' do
    context '有効なパラメータの場合' do
      it '商品が作成される' do
        expect {
          post :create, params: {
            item: {
              name: 'テスト商品',
              stock_quantity: 100,
              unit: '個',
              category_id: category.id,
              location_id: location.id,
              supplier_id: supplier.id,
              description: 'テスト用商品',
              sku: 'TEST-001',
              min_stock: 10,
              max_stock: 200
            }
          }
        }.to change(Item, :count).by(1)
        
        expect(response).to redirect_to(items_path)
        expect(flash[:notice]).to eq('物品が正常に作成されました。')
      end
    end

    context '無効なパラメータの場合' do
      it '商品が作成されない' do
        expect {
          post :create, params: {
            item: {
              name: '',
              stock_quantity: -1
            }
          }
        }.not_to change(Item, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq('物品の作成に失敗しました。')
      end
    end
  end

  describe 'GET #edit' do
    it '商品編集ページが表示される' do
      get :edit, params: { id: item.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:item)).to eq(item)
      expect(assigns(:categories)).to eq(company.categories)
      expect(assigns(:locations)).to eq(company.locations)
      expect(assigns(:suppliers)).to eq(company.suppliers)
    end

    it '他社の商品を編集しようとすると権限エラーになる' do
      other_company = create(:company)
      other_category = create(:category, company: other_company)
      other_location = create(:location, company: other_company)
      other_supplier = create(:supplier, company: other_company)
      other_item = create(:item, company: other_company, category: other_category, location: other_location, supplier: other_supplier)
      
      # パラメータを設定してset_itemメソッドをテスト
      controller.params[:id] = other_item.id
      expect {
        controller.send(:set_item)
      }.to raise_error(Pundit::NotAuthorizedError, "この操作を実行する権限がありません。")
    end
  end

  describe 'PATCH #update' do
    context '有効なパラメータの場合' do
      it '商品が更新される' do
        patch :update, params: {
          id: item.id,
          item: {
            name: '更新された商品名',
            stock_quantity: 150
          }
        }
        
        expect(response).to redirect_to(item_path(item))
        expect(flash[:notice]).to eq('物品が正常に更新されました。')
        expect(item.reload.name).to eq('更新された商品名')
        expect(item.reload.stock_quantity).to eq(150)
      end
    end

    context '無効なパラメータの場合' do
      it '商品が更新されない' do
        patch :update, params: {
          id: item.id,
          item: {
            name: '',
            stock_quantity: -1
          }
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq('物品の更新に失敗しました。')
      end
    end

    it '他社の商品を更新しようとすると権限エラーになる' do
      other_company = create(:company)
      other_category = create(:category, company: other_company)
      other_location = create(:location, company: other_company)
      other_supplier = create(:supplier, company: other_company)
      other_item = create(:item, company: other_company, category: other_category, location: other_location, supplier: other_supplier)
      
      # パラメータを設定してset_itemメソッドをテスト
      controller.params[:id] = other_item.id
      expect {
        controller.send(:set_item)
      }.to raise_error(Pundit::NotAuthorizedError, "この操作を実行する権限がありません。")
    end
  end

  describe 'DELETE #destroy' do
    it '商品が削除される' do
      item_name = item.name
      expect {
        delete :destroy, params: { id: item.id }
      }.to change(Item, :count).by(-1)
      
      expect(response).to redirect_to(items_path)
      expect(flash[:notice]).to eq("「#{item_name}」が正常に削除されました。")
    end

    it '他社の商品を削除しようとすると権限エラーになる' do
      other_company = create(:company)
      other_category = create(:category, company: other_company)
      other_location = create(:location, company: other_company)
      other_supplier = create(:supplier, company: other_company)
      other_item = create(:item, company: other_company, category: other_category, location: other_location, supplier: other_supplier)
      
      # パラメータを設定してset_itemメソッドをテスト
      controller.params[:id] = other_item.id
      expect {
        controller.send(:set_item)
      }.to raise_error(Pundit::NotAuthorizedError, "この操作を実行する権限がありません。")
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
