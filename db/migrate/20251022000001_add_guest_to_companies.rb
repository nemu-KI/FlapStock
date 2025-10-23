# frozen_string_literal: true

class AddGuestToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :guest, :boolean, default: false, null: false
  end
end

