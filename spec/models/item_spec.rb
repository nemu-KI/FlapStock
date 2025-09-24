# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:stock_quantity).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:min_stock).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:max_stock).is_greater_than_or_equal_to(0) }

    describe '最大在庫数が最小在庫数より大きいことのバリデーション' do
      let(:company) { create(:company) }
      let(:category) { create(:category, company: company) }
      let(:location) { create(:location, company: company) }
      let(:supplier) { create(:supplier, company: company) }

      context '最小在庫数と最大在庫数が両方設定されている場合' do
        it '最大在庫数が最小在庫数より大きい場合は有効である' do
          item = build(:item,
                       company: company,
                       category: category,
                       location: location,
                       supplier: supplier,
                       min_stock: 10,
                       max_stock: 20)
          expect(item).to be_valid
        end

        it '最大在庫数が最小在庫数以下の場合は無効である' do
          item = build(:item,
                       company: company,
                       category: category,
                       location: location,
                       supplier: supplier,
                       min_stock: 20,
                       max_stock: 10)
          expect(item).not_to be_valid
          expect(item.errors[:max_stock]).to include('は最小在庫より大きい値で入力してください')
        end
      end

      context '最小在庫数または最大在庫数がnilの場合' do
        it '最小在庫数がnilの場合は有効である' do
          item = build(:item,
                       company: company,
                       category: category,
                       location: location,
                       supplier: supplier,
                       min_stock: nil,
                       max_stock: 20)
          expect(item).to be_valid
        end

        it '最大在庫数がnilの場合は有効である' do
          item = build(:item,
                       company: company,
                       category: category,
                       location: location,
                       supplier: supplier,
                       min_stock: 10,
                       max_stock: nil)
          expect(item).to be_valid
        end
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:category) }
    it { should belong_to(:location) }
    it { should belong_to(:supplier) }
    it { should have_many(:stock_movements).dependent(:destroy) }
  end

  describe 'Ransack検索可能な属性' do
    it '正しい検索可能な属性を返す' do
      expected_attributes = %w[name sku stock_quantity unit description min_stock max_stock created_at updated_at]
      expect(Item.ransackable_attributes).to match_array(expected_attributes)
    end
  end

  describe 'Ransack検索可能な関連' do
    it '正しい検索可能な関連を返す' do
      expected_associations = %w[category location supplier]
      expect(Item.ransackable_associations).to match_array(expected_associations)
    end
  end

  describe '画像添付' do
    it '画像を1つ添付できる' do
      item = create(:item)
      expect(item.image).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end
end
