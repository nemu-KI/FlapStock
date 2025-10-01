require 'rails_helper'

RSpec.describe Contact, type: :model do
  let(:user) { create(:user) }
  let(:company) { user.company }
  let(:contact) { build(:contact, user: user, company: company) }

  describe 'アソシエーション' do
    it { should belong_to(:user).optional }
    it { should belong_to(:company).optional }
  end

  describe 'バリデーション' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:message) }

    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_length_of(:subject).is_at_most(200) }
    it { should validate_length_of(:message).is_at_most(2000) }

    it 'categoryが有効な値であること' do
      contact.category = 'bug'
      expect(contact).to be_valid

      # 無効な値を設定する前に、有効な値に戻す
      contact.category = 'bug'
      contact.valid?
      expect(contact.errors[:category]).to be_empty
    end

    it 'priorityが有効な値であること' do
      contact.priority = 'high'
      expect(contact).to be_valid

      # 無効な値を設定する前に、有効な値に戻す
      contact.priority = 'high'
      contact.valid?
      expect(contact.errors[:priority]).to be_empty
    end

    it 'statusが有効な値であること' do
      contact.status = 'pending'
      expect(contact).to be_valid

      # 無効な値を設定する前に、有効な値に戻す
      contact.status = 'pending'
      contact.valid?
      expect(contact.errors[:status]).to be_empty
    end

    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
  end

  describe '列挙型' do
    it 'categoryが正しく定義されていること' do
      expect(Contact.categories).to eq({ 'bug' => 'bug', 'feature' => 'feature', 'other' => 'other' })
    end

    it 'priorityが正しく定義されていること' do
      expect(Contact.priorities).to eq({ 'high' => 'high', 'medium' => 'medium', 'low' => 'low' })
    end

    it 'statusが正しく定義されていること' do
      expect(Contact.statuses).to eq({ 'pending' => 'pending', 'in_progress' => 'in_progress', 'completed' => 'completed' })
    end
  end

  describe 'スコープ' do
    before do
      Contact.delete_all # 既存データをクリア
    end

    let!(:contact1) { create(:contact, created_at: 1.day.ago) }
    let!(:contact2) { create(:contact, created_at: 2.days.ago) }

    describe '.recent' do
      it '作成日時の降順でお問い合わせを返すこと' do
        expect(Contact.recent).to eq([contact1, contact2])
      end
    end

    describe '.by_category' do
      let!(:bug_contact) { create(:contact, category: 'bug') }
      let!(:feature_contact) { create(:contact, category: 'feature') }

      it 'カテゴリでフィルタリングされたお問い合わせを返すこと' do
        expect(Contact.by_category('bug')).to include(bug_contact)
        expect(Contact.by_category('bug')).not_to include(feature_contact)
      end
    end

    describe '.by_status' do
      let!(:pending_contact) { create(:contact, status: 'pending') }
      let!(:completed_contact) { create(:contact, status: 'completed') }

      it 'ステータスでフィルタリングされたお問い合わせを返すこと' do
        expect(Contact.by_status('pending')).to include(pending_contact)
        expect(Contact.by_status('pending')).not_to include(completed_contact)
      end
    end
  end

  describe 'ラベルメソッド' do
    it '正しいカテゴリラベルを返すこと' do
      contact.category = 'bug'
      expect(contact.category_label).to eq('バグ報告')
    end

    it '正しい優先度ラベルを返すこと' do
      contact.priority = 'high'
      expect(contact.priority_label).to eq('高')
    end

    it '正しいステータスラベルを返すこと' do
      contact.status = 'pending'
      expect(contact.status_label).to eq('未対応')
    end
  end
end
