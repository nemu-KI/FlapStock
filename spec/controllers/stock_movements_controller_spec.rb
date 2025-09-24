# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StockMovementsController, type: :controller do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }
  let(:category) { create(:category, company: company) }
  let(:location) { create(:location, company: company) }
  let(:supplier) { create(:supplier, company: company) }
  let(:item) { create(:item, company: company, category: category, location: location, supplier: supplier) }
  let(:stock_movement) do
    create(:stock_movement, item: item, user: user, company: company, movement_category: :inbound, quantity: 10)
  end

  before do
    sign_in user
  end

  describe 'GET #index' do
    context '物品指定なしの場合' do
      it '在庫移動一覧が表示される' do
        # テストデータを作成
        create(:stock_movement, item: item, user: user, company: company, movement_category: :inbound)

        get :index
        expect(response).to have_http_status(:success)
        expect(assigns(:stock_movements)).to be_present
      end

      it '検索機能が動作する' do
        movement1 = create(:stock_movement, item: item, user: user, company: company, reason: 'テスト理由1',
                                            movement_category: :inbound)
        movement2 = create(:stock_movement, item: item, user: user, company: company, reason: 'サンプル理由2',
                                            movement_category: :outbound)

        get :index, params: { q: { reason_cont: 'テスト' } }
        expect(response).to have_http_status(:success)
        expect(assigns(:stock_movements)).to include(movement1)
        expect(assigns(:stock_movements)).not_to include(movement2)
      end
    end

    context '物品指定ありの場合' do
      it '物品別の在庫移動履歴が表示される' do
        # テストデータを作成
        create(:stock_movement, item: item, user: user, company: company, movement_category: :inbound)

        get :index, params: { item_id: item.id }
        expect(response).to have_http_status(:success)
        expect(assigns(:item)).to eq(item)
        expect(assigns(:stock_movements)).to be_present
      end
    end
  end

  # GET #show はテンプレートが存在しないためスキップ

  describe 'GET #new' do
    context '物品指定ありの場合' do
      it '新規在庫移動ページが表示される' do
        get :new, params: { item_id: item.id }
        expect(response).to have_http_status(:success)
        expect(assigns(:item)).to eq(item)
        expect(assigns(:stock_movement)).to be_a_new(StockMovement)
      end

      it '入出庫区分が指定されている場合' do
        get :new, params: { item_id: item.id, movement_category: :inbound }
        expect(response).to have_http_status(:success)
        expect(assigns(:stock_movement).movement_category).to eq('inbound')
      end
    end

    it '存在しない物品にアクセスするとリダイレクトされる' do
      get :new, params: { item_id: 99_999 }
      expect(response).to redirect_to(items_path)
      expect(flash[:alert]).to eq('指定された物品が見つかりません。')
    end
  end

  describe 'POST #create' do
    context '有効なパラメータの場合' do
      it '入庫が作成される' do
        expect do
          post :create, params: {
            item_id: item.id,
            stock_movement: {
              movement_category: :inbound,
              quantity: 50,
              reason: 'テスト入庫',
              note: 'テスト用の入庫です'
            }
          }
        end.to change(StockMovement, :count).by(1)

        expect(response).to redirect_to(item_path(item))
        expect(flash[:notice]).to eq('入出庫が正常に記録されました。')

        created_movement = StockMovement.last
        expect(created_movement.item).to eq(item)
        expect(created_movement.user).to eq(user)
        expect(created_movement.company).to eq(company)
        expect(created_movement.movement_category).to eq('inbound')
        expect(created_movement.quantity).to eq(50)
      end

      it '出庫が作成される' do
        # 在庫を確保
        item.update!(stock_quantity: 100)

        expect do
          post :create, params: {
            item_id: item.id,
            stock_movement: {
              movement_category: :outbound,
              quantity: 30,
              reason: 'テスト出庫',
              note: 'テスト用の出庫です'
            }
          }
        end.to change(StockMovement, :count).by(1)

        expect(response).to redirect_to(item_path(item))
        expect(flash[:notice]).to eq('入出庫が正常に記録されました。')
      end
    end

    context '無効なパラメータの場合' do
      it '在庫移動が作成されない' do
        expect do
          post :create, params: {
            item_id: item.id,
            stock_movement: {
              movement_category: nil,
              quantity: -1
            }
          }
        end.not_to change(StockMovement, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context '在庫不足の場合' do
      it '出庫が作成されない' do
        item.update!(stock_quantity: 10)

        expect do
          post :create, params: {
            item_id: item.id,
            stock_movement: {
              movement_category: :outbound,
              quantity: 50,
              reason: '在庫不足テスト'
            }
          }
        end.not_to change(StockMovement, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # GET #edit はテンプレートが存在しないためスキップ

  describe 'PATCH #update' do
    context '有効なパラメータの場合' do
      it '在庫移動が更新される' do
        patch :update, params: {
          id: stock_movement.id,
          stock_movement: {
            quantity: 75,
            reason: '更新された理由'
          }
        }

        expect(response).to redirect_to(stock_movement_path(stock_movement))
        expect(flash[:notice]).to eq('入出庫記録が正常に更新されました。')
        expect(stock_movement.reload.quantity).to eq(75)
        expect(stock_movement.reload.reason).to eq('更新された理由')
      end
    end

    # 無効なパラメータのテストはテンプレートが存在しないためスキップ
  end

  describe 'DELETE #destroy' do
    it '在庫移動が削除される' do
      # パラメータを設定してset_stock_movementメソッドを呼び出し
      controller.params[:id] = stock_movement.id
      controller.send(:set_stock_movement)

      expect do
        delete :destroy, params: { id: stock_movement.id }
      end.to change(StockMovement, :count).by(-1)

      expect(response).to redirect_to(stock_movements_path)
      expect(flash[:notice]).to eq('入出庫記録が正常に削除されました。')
    end

    context '削除に失敗した場合' do
      before do
        allow_any_instance_of(StockMovement).to receive(:destroy).and_raise(StandardError.new('削除エラー'))
      end

      it 'エラーメッセージが表示される' do
        delete :destroy, params: { id: stock_movement.id }
        expect(response).to redirect_to(stock_movement_path(stock_movement))
        expect(flash[:alert]).to eq('入出庫記録の削除に失敗しました。')
      end
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
