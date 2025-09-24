# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should belong_to(:company) }
    it { should have_many(:stock_movements).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(staff: 0, manager: 1, admin: 2) }
  end

  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes validatable' do
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe 'コールバック' do
    let(:company) { create(:company) }

    describe '作成前の管理者権限設定' do
      it '作成時にroleをadminに設定する' do
        user = build(:user, company: company, role: nil)
        user.save
        expect(user.role).to eq('admin')
      end
    end

    describe '作成前の会社検索・作成' do
      it 'company_nameが提供された場合に会社を作成する' do
        user = build(:user, company_name: 'Test Company')
        user.save
        expect(user.company).to be_persisted
        expect(user.company.name).to eq('Test Company')
      end

      it 'company_nameが一致する場合に既存の会社を見つける' do
        existing_company = create(:company, name: 'Existing Company')
        user = build(:user, company_name: 'Existing Company')
        user.save
        expect(user.company).to eq(existing_company)
      end
    end

    describe '作成後の管理者権限確保' do
      it '作成後に管理者権限を確保する' do
        user = build(:user, company: company, role: 'staff')
        user.save
        expect(user.reload.role).to eq('admin')
      end
    end
  end

  describe 'Ransack検索可能な属性' do
    it '正しい検索可能な属性を返す' do
      expected_attributes = %w[id email role company_id created_at updated_at]
      expect(User.send(:ransackable_attributes)).to match_array(expected_attributes)
    end
  end

  describe 'Ransack検索可能な関連' do
    it '正しい検索可能な関連を返す' do
      expected_associations = %w[company stock_movements]
      expect(User.send(:ransackable_associations)).to match_array(expected_associations)
    end
  end
end
