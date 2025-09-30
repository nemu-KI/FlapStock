# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should belong_to(:company) }
    it { should have_many(:items).dependent(:restrict_with_error) }
  end

  describe 'ransackable attributes' do
    it 'returns correct ransackable attributes' do
      expected_attributes = %w[id name description company_id created_at updated_at]
      expect(Location.ransackable_attributes).to match_array(expected_attributes)
    end
  end

  describe 'ransackable associations' do
    it 'returns correct ransackable associations' do
      expected_associations = %w[company items]
      expect(Location.ransackable_associations).to match_array(expected_associations)
    end
  end
end
