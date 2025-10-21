# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanySettingsController, type: :controller do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company, role: :admin) }

  before do
    sign_in user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end

    it 'assigns @company' do
      get :show
      expect(assigns(:company)).to eq(company)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit
      expect(response).to have_http_status(:success)
    end

    it 'assigns @company' do
      get :edit
      expect(assigns(:company)).to eq(company)
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          company: {
            name: 'Updated Company',
            email: 'updated@example.com',
            phone: '03-1234-5678',
            address: '東京都渋谷区',
            timezone: 'Tokyo'
          }
        }
      end

      it 'updates the company' do
        patch :update, params: valid_params
        company.reload
        expect(company.name).to eq('Updated Company')
        expect(company.email).to eq('updated@example.com')
        expect(company.phone).to eq('03-1234-5678')
        expect(company.address).to eq('東京都渋谷区')
        expect(company.timezone).to eq('Tokyo')
      end

      it 'redirects to settings page' do
        patch :update, params: valid_params
        expect(response).to redirect_to(settings_path)
      end

      it 'sets success notice' do
        patch :update, params: valid_params
        expect(flash[:notice]).to eq('会社情報を更新しました。')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          company: {
            name: '',
            email: 'invalid-email',
            phone: 'invalid-phone',
            timezone: 'Invalid/Timezone'
          }
        }
      end

      it 'does not update the company' do
        patch :update, params: invalid_params
        company.reload
        expect(company.name).not_to eq('')
      end

      it 'renders edit template' do
        patch :update, params: invalid_params
        expect(response).to render_template(:edit)
      end

      it 'returns unprocessable_entity status' do
        patch :update, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'authorization' do
    context 'when user is not admin' do
      let(:non_admin_user) { create(:user, company: company, role: :staff) }

      before do
        sign_in non_admin_user
      end

      # TODO: 将来のrole管理実装時に有効化
      xit 'denies access to show' do
        expect { get :show }.to raise_error(Pundit::NotAuthorizedError)
      end

      xit 'denies access to edit' do
        expect { get :edit }.to raise_error(Pundit::NotAuthorizedError)
      end

      xit 'denies access to update' do
        expect { patch :update, params: { company: { name: 'Test' } } }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
