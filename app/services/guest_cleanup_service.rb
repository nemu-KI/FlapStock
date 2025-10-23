# frozen_string_literal: true

# ゲストデータのクリーンアップサービス
class GuestCleanupService
  def self.cleanup_old_guests
    puts '=== ゲストデータのクリーンアップを開始 ==='

    old_guests = User.where('email LIKE ? AND created_at < ?', 'guest_%@example.com', 1.hour.ago)

    if old_guests.any?
      puts "古いゲストユーザー #{old_guests.count} 件を削除中..."
      old_guests.each do |user|
        user.stock_movements.destroy_all
        user.destroy!
      end
      puts "古いゲストユーザー #{old_guests.count} 件を削除しました"
    else
      puts '削除対象の古いゲストユーザーはありません'
    end

    puts '=== クリーンアップ完了 ==='
  end

  def self.reset_all_guest_data
    puts '=== ゲストデータの完全リセットを開始 ==='

    guest_users = User.where('email LIKE ?', 'guest_%@example.com')

    if guest_users.any?
      puts "全ゲストユーザー #{guest_users.count} 件を削除中..."
      guest_users.each(&:destroy!)
      puts '全ゲストユーザーを削除しました'
    end

    puts 'ゲスト企業データを完全リセット中...'
    Rake::Task['guest:reset'].invoke
    Rake::Task['guest:setup'].invoke
    Rake::Task['guest:sample_data'].invoke

    puts '=== 完全リセット完了 ==='
  end

  def self.reset_company_data
    puts '=== ゲスト企業データのリセットを開始 ==='

    guest_company = find_guest_company
    return unless guest_company

    puts 'ゲスト企業のデータをリセット中...'
    reset_guest_company_data(guest_company)
    Rake::Task['guest:sample_data'].invoke
    puts 'ゲスト企業データのリセットが完了しました'
  end

  def self.show_stats
    puts '=== ゲストデータの統計情報 ==='

    guest_companies = Company.where(name: 'ゲスト企業', email: 'guest@example.com')
    puts "ゲスト企業数: #{guest_companies.count}"

    guest_users = User.where('email LIKE ?', 'guest_%@example.com')
    puts "ゲストユーザー数: #{guest_users.count}"

    old_guests = User.where('email LIKE ? AND created_at < ?', 'guest_%@example.com', 1.hour.ago)
    puts "古いゲストユーザー数（1時間以上前）: #{old_guests.count}"

    return unless guest_companies.any?

    company = guest_companies.first
    show_company_stats(company)
  end

  private_class_method def self.find_guest_company
    guest_company = Company.find_by(name: 'ゲスト企業', email: 'guest@example.com')

    unless guest_company&.timezone == 'Tokyo' && guest_company&.phone == '03-1234-5678'
      puts '警告: ゲスト企業の識別に失敗しました。本登録企業の可能性があります。'
      puts "対象企業: #{guest_company&.name} (#{guest_company&.email})"
      puts '処理を中断します。'
      return nil
    end

    guest_company
  end

  private_class_method def self.reset_guest_company_data(company)
    puts '在庫移動履歴を削除中...'
    company.stock_movements.destroy_all

    puts '物品を削除中...'
    company.items.destroy_all

    puts 'カテゴリを削除中...'
    company.categories.destroy_all

    puts '場所を削除中...'
    company.locations.destroy_all

    puts '仕入先を削除中...'
    company.suppliers.destroy_all

    puts '新しいサンプルデータを作成中...'
  end

  private_class_method def self.show_company_stats(company)
    show_data_statistics(company)
    show_update_timestamps(company)
    puts '=== 統計情報表示完了 ==='
  end

  private_class_method def self.show_data_statistics(company)
    puts '--- ゲスト企業のデータ統計 ---'
    puts "物品数: #{company.items.count}"
    puts "在庫移動数: #{company.stock_movements.count}"
    puts "カテゴリ数: #{company.categories.count}"
    puts "場所数: #{company.locations.count}"
    puts "仕入先数: #{company.suppliers.count}"
  end

  private_class_method def self.show_update_timestamps(company)
    puts '--- データの最終更新日時 ---'
    puts "企業作成日: #{company.created_at}"
    puts "最新在庫移動: #{company.stock_movements.maximum(:created_at) || 'なし'}"
    puts "最新物品: #{company.items.maximum(:created_at) || 'なし'}"
  end
end
