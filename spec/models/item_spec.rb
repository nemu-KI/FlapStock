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
      expected_attributes = %w[name sku stock_quantity unit description min_stock max_stock category_id location_id
                               supplier_id created_at updated_at]
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

  describe '在庫アラート機能' do
    let(:company) { create(:company) }
    let(:category) { create(:category, company: company) }
    let(:location) { create(:location, company: company) }
    let(:supplier) { create(:supplier, company: company) }

    describe '#stock_alert_status' do
      context 'アラート設定がない場合' do
        it 'normalを返す' do
          item = create(:item, company: company, category: category, location: location, supplier: supplier,
                               min_stock: nil, max_stock: nil)
          expect(item.stock_alert_status).to eq('normal')
        end
      end

      context '在庫不足の場合' do
        it 'low_stockを返す' do
          item = create(:item, company: company, category: category, location: location, supplier: supplier,
                               stock_quantity: 5, min_stock: 10)
          expect(item.stock_alert_status).to eq('low_stock')
        end
      end

      context '在庫過剰の場合' do
        it 'overstockを返す' do
          item = create(:item, company: company, category: category, location: location, supplier: supplier,
                               stock_quantity: 25, max_stock: 20)
          expect(item.stock_alert_status).to eq('overstock')
        end
      end

      context '正常な在庫の場合' do
        it 'normalを返す' do
          item = create(:item, company: company, category: category, location: location, supplier: supplier,
                               stock_quantity: 15, min_stock: 10, max_stock: 20)
          expect(item.stock_alert_status).to eq('normal')
        end
      end
    end

    describe '#needs_alert?' do
      it 'アラートが必要な場合はtrueを返す' do
        item = create(:item, company: company, category: category, location: location, supplier: supplier,
                             stock_quantity: 5, min_stock: 10)
        expect(item.needs_alert?).to be true
      end

      it 'アラートが不要な場合はfalseを返す' do
        item = create(:item, company: company, category: category, location: location, supplier: supplier,
                             stock_quantity: 15, min_stock: 10, max_stock: 20)
        expect(item.needs_alert?).to be false
      end
    end

    describe '#alert_message' do
      it '在庫不足の場合のメッセージを返す' do
        item = create(:item, company: company, category: category, location: location, supplier: supplier,
                             stock_quantity: 5, min_stock: 10, unit: '個')
        expect(item.alert_message).to eq('在庫不足（現在: 5個、最小在庫: 10個）')
      end

      it '在庫過剰の場合のメッセージを返す' do
        item = create(:item, company: company, category: category, location: location, supplier: supplier,
                             stock_quantity: 25, max_stock: 20, unit: '個')
        expect(item.alert_message).to eq('在庫過剰（現在: 25個、最大在庫: 20個）')
      end

      it '正常な場合はnilを返す' do
        item = create(:item, company: company, category: category, location: location, supplier: supplier,
                             stock_quantity: 15, min_stock: 10, max_stock: 20)
        expect(item.alert_message).to be_nil
      end
    end

    describe 'スコープ' do
      let!(:low_stock_item) do
        create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 5,
                      min_stock: 10)
      end
      let!(:overstock_item) do
        create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 25,
                      max_stock: 20)
      end
      let!(:normal_item) do
        create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 15,
                      min_stock: 10, max_stock: 20)
      end

      describe '.low_stock' do
        it '在庫不足の物品のみを返す' do
          low_stock_items = Item.low_stock.where(company: company)
          expect(low_stock_items.count).to eq(1)
          expect(low_stock_items.first).to eq(low_stock_item)
        end
      end

      describe '.overstock' do
        it '在庫過剰の物品のみを返す' do
          overstock_items = Item.overstock.where(company: company)
          expect(overstock_items.count).to eq(1)
          expect(overstock_items.first).to eq(overstock_item)
        end
      end

      describe '.with_stock_alerts' do
        it 'アラート設定済みの物品を返す' do
          alert_items = Item.with_stock_alerts.where(company: company)
          expect(alert_items.count).to eq(3)
          expect(alert_items).to include(low_stock_item, overstock_item, normal_item)
        end
      end
    end
  end
end
