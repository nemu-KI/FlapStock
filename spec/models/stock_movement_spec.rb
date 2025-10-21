# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StockMovement, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_presence_of(:movement_category) }
    it { should validate_presence_of(:reason) }
    it { should validate_length_of(:reason).is_at_most(100) }
    it { should validate_length_of(:note).is_at_most(500) }

    describe '在庫不足チェック' do
      let(:company) { create(:company) }
      let(:category) { create(:category, company: company) }
      let(:location) { create(:location, company: company) }
      let(:supplier) { create(:supplier, company: company) }
      let(:user) { create(:user, company: company) }
      let(:item) do
        create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 10)
      end

      context '入出庫区分が出庫の場合' do
        it '数量が在庫数以下の場合は有効である' do
          stock_movement = build(:stock_movement,
                                 company: company,
                                 user: user,
                                 item: item,
                                 movement_category: :outbound,
                                 quantity: 5)
          expect(stock_movement).to be_valid
        end

        it '数量が在庫数を超える場合は無効である' do
          stock_movement = build(:stock_movement,
                                 company: company,
                                 user: user,
                                 item: item,
                                 movement_category: :outbound,
                                 quantity: 15)
          expect(stock_movement).not_to be_valid
          expect(stock_movement.errors[:quantity]).to include('現在の在庫数（10個）を超える出庫はできません')
        end
      end

      context '入出庫区分が出庫以外の場合' do
        it '入庫の場合は有効である' do
          stock_movement = build(:stock_movement,
                                 company: company,
                                 user: user,
                                 item: item,
                                 movement_category: :inbound,
                                 quantity: 15)
          expect(stock_movement).to be_valid
        end

        it '調整の場合は有効である' do
          stock_movement = build(:stock_movement,
                                 company: company,
                                 user: user,
                                 item: item,
                                 movement_category: :adjustment,
                                 quantity: 15)
          expect(stock_movement).to be_valid
        end
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:user) }
    it { should belong_to(:item) }
  end

  describe 'enums' do
    it { should define_enum_for(:movement_category).with_values(inbound: 0, outbound: 1, adjustment: 2) }
  end

  describe 'callbacks' do
    let(:company) { create(:company) }
    let(:category) { create(:category, company: company) }
    let(:location) { create(:location, company: company) }
    let(:supplier) { create(:supplier, company: company) }
    let(:user) { create(:user, company: company) }
    let(:item) do
      create(:item, company: company, category: category, location: location, supplier: supplier, stock_quantity: 10)
    end

    describe '作成後の在庫更新' do
      context '入出庫区分が入庫の場合' do
        it '物品の在庫数を増加させる' do
          expect do
            create(:stock_movement,
                   company: company,
                   user: user,
                   item: item,
                   movement_category: :inbound,
                   quantity: 5)
          end.to change { item.reload.stock_quantity }.by(5)
        end
      end

      context '入出庫区分が出庫の場合' do
        it '物品の在庫数を減少させる' do
          expect do
            create(:stock_movement,
                   company: company,
                   user: user,
                   item: item,
                   movement_category: :outbound,
                   quantity: 3)
          end.to change { item.reload.stock_quantity }.by(-3)
        end
      end

      context '入出庫区分が調整の場合' do
        it '物品の在庫数を数量に設定する' do
          create(:stock_movement,
                 company: company,
                 user: user,
                 item: item,
                 movement_category: :adjustment,
                 quantity: 25)
          expect(item.reload.stock_quantity).to eq(25)
        end
      end
    end

    describe '削除前の調整レコードチェック' do
      it '調整レコードの削除を防ぐ' do
        stock_movement = create(:stock_movement,
                                company: company,
                                user: user,
                                item: item,
                                movement_category: :adjustment,
                                quantity: 5)
        expect { stock_movement.destroy }.not_to(change { StockMovement.count })
        expect(stock_movement.errors[:base]).to be_present
      end

      it '調整以外のレコードの削除を許可する' do
        stock_movement = create(:stock_movement,
                                company: company,
                                user: user,
                                item: item,
                                movement_category: :inbound,
                                quantity: 5)
        expect { stock_movement.destroy }.to change { StockMovement.count }.by(-1)
      end
    end

    describe '削除後の在庫復元' do
      context '入出庫区分が入庫の場合' do
        it '物品の在庫数を減少させる' do
          stock_movement = create(:stock_movement,
                                  company: company,
                                  user: user,
                                  item: item,
                                  movement_category: :inbound,
                                  quantity: 5)
          expect do
            stock_movement.destroy
          end.to change { item.reload.stock_quantity }.by(-5)
        end
      end

      context '入出庫区分が出庫の場合' do
        it '物品の在庫数を増加させる' do
          stock_movement = create(:stock_movement,
                                  company: company,
                                  user: user,
                                  item: item,
                                  movement_category: :outbound,
                                  quantity: 3)
          expect do
            stock_movement.destroy
          end.to change { item.reload.stock_quantity }.by(3)
        end
      end
    end
  end

  describe 'scopes' do
    let(:company) { create(:company) }
    let(:category) { create(:category, company: company) }
    let(:location) { create(:location, company: company) }
    let(:supplier) { create(:supplier, company: company) }
    let(:user) { create(:user, company: company) }
    let(:item) { create(:item, company: company, category: category, location: location, supplier: supplier) }

    before do
      create(:stock_movement, company: company, user: user, item: item, movement_category: :inbound)
      build(:stock_movement, company: company, user: user, item: item, movement_category: :outbound, quantity: 5).save!
      create(:stock_movement, company: company, user: user, item: item, movement_category: :adjustment)
    end

    describe '.with_movement_category' do
      it '入出庫区分でフィルタリングする' do
        inbound_movements = StockMovement.with_movement_category(:inbound)
        expect(inbound_movements.count).to be >= 1
        expect(inbound_movements.first.movement_category).to eq('inbound')
      end

      it '区分がnilの場合は全レコードを返す' do
        all_movements = StockMovement.with_movement_category(nil)
        expect(all_movements.count).to be >= 3
      end
    end
  end

  describe 'Ransack検索可能な属性' do
    it '正しい検索可能な属性を返す' do
      expected_attributes = %w[id quantity reason note created_at updated_at]
      expect(StockMovement.ransackable_attributes).to match_array(expected_attributes)
    end
  end

  describe 'Ransack検索可能な関連' do
    it '正しい検索可能な関連を返す' do
      expected_associations = %w[item user company]
      expect(StockMovement.ransackable_associations).to match_array(expected_associations)
    end
  end

  describe 'Ransack検索可能なスコープ' do
    it '正しい検索可能なスコープを返す' do
      expected_scopes = %w[with_movement_category]
      expect(StockMovement.ransackable_scopes).to match_array(expected_scopes)
    end
  end

  describe '#movement_category_i18n' do
    let(:company) { create(:company) }
    let(:category) { create(:category, company: company) }
    let(:location) { create(:location, company: company) }
    let(:supplier) { create(:supplier, company: company) }
    let(:user) { create(:user, company: company) }
    let(:item) { create(:item, company: company, category: category, location: location, supplier: supplier) }

    it '入出庫区分のi18nキーを返す' do
      stock_movement = create(:stock_movement,
                              company: company,
                              user: user,
                              item: item,
                              movement_category: :inbound)
      expected_value = I18n.t('activerecord.enums.stock_movement.movement_category.inbound')
      expect(stock_movement.movement_category_i18n).to eq(expected_value)
    end
  end

  describe 'アラート通知機能' do
    let(:company) { create(:company, email_notifications_enabled: true) }
    let(:category) { create(:category, company: company) }
    let(:location) { create(:location, company: company) }
    let(:supplier) { create(:supplier, company: company) }
    let(:admin_user) { create(:user, company: company, role: :admin) }
    let(:manager_user) { create(:user, company: company, role: :manager) }

    context '在庫不足アラートが発生する場合' do
      let(:item) do
        create(:item,
               company: company,
               category: category,
               location: location,
               supplier: supplier,
               stock_quantity: 10,
               min_stock: 15,
               unit: '個')
      end

      it '出庫時にアラートメールが送信される' do
        expect do
          create(:stock_movement,
                 company: company,
                 user: admin_user,
                 item: item,
                 movement_category: :outbound,
                 quantity: 5)
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        mail = ActionMailer::Base.deliveries.last
        # 会社の管理者・マネージャーにメールが送信されることを確認
        expect(mail.to).not_to be_empty
        expect(mail.subject).to include('在庫アラート')
      end
    end

    context '在庫過剰アラートが発生する場合' do
      let(:item) do
        create(:item,
               company: company,
               category: category,
               location: location,
               supplier: supplier,
               stock_quantity: 10,
               max_stock: 15,
               unit: '個')
      end

      it '入庫時にアラートメールが送信される' do
        expect do
          create(:stock_movement,
                 company: company,
                 user: admin_user,
                 item: item,
                 movement_category: :inbound,
                 quantity: 10)
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        mail = ActionMailer::Base.deliveries.last
        # 会社の管理者・マネージャーにメールが送信されることを確認
        expect(mail.to).not_to be_empty
        expect(mail.subject).to include('在庫アラート')
      end
    end

    context 'アラートが発生しない場合' do
      let(:item) do
        create(:item,
               company: company,
               category: category,
               location: location,
               supplier: supplier,
               stock_quantity: 20,
               min_stock: 10,
               max_stock: 30,
               unit: '個')
      end

      it 'メールが送信されない' do
        expect do
          create(:stock_movement,
                 company: company,
                 user: admin_user,
                 item: item,
                 movement_category: :inbound,
                 quantity: 5)
        end.not_to(change { ActionMailer::Base.deliveries.count })
      end
    end
  end
end
