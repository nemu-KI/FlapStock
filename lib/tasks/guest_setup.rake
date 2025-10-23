# frozen_string_literal: true

namespace :guest do
  desc 'ゲスト企業とユーザーを作成'
  task setup: :environment do
    GuestSetupService.setup_guest_company_and_user
  end

  desc 'ゲスト企業のサンプルデータを作成'
  task sample_data: :environment do
    GuestSetupService.create_sample_data
  end

  desc 'ゲスト企業のデータをリセット'
  task reset: :environment do
    GuestSetupService.reset_guest_data
  end
end
