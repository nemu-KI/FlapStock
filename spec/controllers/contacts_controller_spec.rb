# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  let(:user) { create(:user) }
  let(:company) { user.company }
  let(:valid_attributes) do
    {
      name: 'テストユーザー',
      email: 'test@example.com',
      category: 'bug',
      priority: 'high',
      subject: 'テスト件名',
      message: 'テストメッセージ'
    }
  end

  before do
    sign_in user
  end

  describe 'GET #new' do
    it '正常にレスポンスを返すこと' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it '新しいお問い合わせオブジェクトを割り当てること' do
      get :new
      expect(assigns(:contact)).to be_a_new(Contact)
    end

    it 'ユーザーと会社を設定すること' do
      get :new
      expect(assigns(:contact).user).to eq(user)
      expect(assigns(:contact).company).to eq(company)
    end
  end

  describe 'POST #create' do
    context '有効なパラメータの場合' do
      it '新しいお問い合わせを作成すること' do
        expect do
          post :create, params: { contact: valid_attributes }
        end.to change(Contact, :count).by(1)
      end

      it '確認ページにリダイレクトすること' do
        post :create, params: { contact: valid_attributes }
        expect(response).to redirect_to(contact_confirm_path(id: Contact.last.id))
      end

      it '即座にメールを送信しないこと' do
        expect do
          post :create, params: { contact: valid_attributes }
        end.not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context '無効なパラメータの場合' do
      let(:invalid_attributes) { { name: '', email: 'invalid' } }

      it '新しいお問い合わせを作成しないこと' do
        expect do
          post :create, params: { contact: invalid_attributes }
        end.not_to change(Contact, :count)
      end

      it 'newテンプレートをレンダリングすること' do
        post :create, params: { contact: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET #confirm' do
    let(:contact) { create(:contact, user: user, company: company) }

    it '正常にレスポンスを返すこと' do
      get :confirm, params: { id: contact.id }
      expect(response).to have_http_status(:success)
    end

    it 'お問い合わせオブジェクトを割り当てること' do
      get :confirm, params: { id: contact.id }
      expect(assigns(:contact)).to eq(contact)
    end
  end

  describe 'POST #complete' do
    let(:contact) { create(:contact, user: user, company: company) }

    it 'メール通知を送信すること' do
      expect do
        post :complete, params: { id: contact.id }
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it '完了ページにリダイレクトすること' do
      post :complete, params: { id: contact.id }
      expect(response).to redirect_to(contact_complete_path(id: contact.id))
    end
  end

  describe 'GET #complete' do
    let(:contact) { create(:contact, user: user, company: company) }

    it '正常にレスポンスを返すこと' do
      get :complete, params: { id: contact.id }
      expect(response).to have_http_status(:success)
    end

    it 'お問い合わせオブジェクトを割り当てること' do
      get :complete, params: { id: contact.id }
      expect(assigns(:contact)).to eq(contact)
    end
  end
end
