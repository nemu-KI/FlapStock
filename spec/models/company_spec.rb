# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }

    it 'validates presence of email' do
      company = build(:company, email: nil)
      expect(company).not_to be_valid
      expect(company.errors[:email]).to include("を入力してください")
    end
  end

  describe 'associations' do
    it { should have_many(:users).dependent(:destroy) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:locations).dependent(:destroy) }
    it { should have_many(:suppliers).dependent(:destroy) }
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:stock_movements).dependent(:destroy) }
  end

  describe 'デフォルト値' do
    it 'デフォルトでactiveがtrueに設定される' do
      company = create(:company)
      expect(company.active).to be true
    end
  end
end
