require 'rails_helper'

RSpec.describe Supplier, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should belong_to(:company) }
    it { should have_many(:items).dependent(:destroy) }
  end

  describe 'ransackable attributes' do
    it 'returns correct ransackable attributes' do
      expected_attributes = %w[id name email phone address contact_person note company_id created_at updated_at]
      expect(Supplier.ransackable_attributes).to match_array(expected_attributes)
    end
  end

  describe 'ransackable associations' do
    it 'returns correct ransackable associations' do
      expected_associations = %w[company items]
      expect(Supplier.ransackable_associations).to match_array(expected_associations)
    end
  end
end
