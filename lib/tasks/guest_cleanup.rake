# frozen_string_literal: true

namespace :guest do
  desc '古いゲストデータをクリーンアップ'
  task cleanup: :environment do
    GuestCleanupService.cleanup_old_guests
  end

  desc 'ゲストデータを完全リセット'
  task reset_all: :environment do
    GuestCleanupService.reset_all_guest_data
  end

  desc 'ゲスト企業のデータをリセット（ユーザーは保持）'
  task reset_company_data: :environment do
    GuestCleanupService.reset_company_data
  end

  desc 'ゲスト企業のデータを完全リセット（ユーザーも削除）'
  task reset_all_with_users: :environment do
    GuestCleanupService.reset_all_guest_data
  end

  desc 'ゲストデータの統計情報を表示'
  task stats: :environment do
    GuestCleanupService.show_stats
  end
end
