# frozen_string_literal: true

namespace :guest do
  desc '古いゲストデータをクリーンアップ'
  task cleanup: :environment do
    puts '=== ゲストデータのクリーンアップを開始 ==='

    # 1時間以上古いゲストユーザーを削除
    old_guests = User.where('email LIKE ? AND created_at < ?', 'guest_%@example.com', 1.hour.ago)

    if old_guests.any?
      puts "古いゲストユーザー #{old_guests.count} 件を削除中..."

      old_guests.each do |user|
        # 関連データを削除
        user.stock_movements.destroy_all
        user.destroy!
      end

      puts "古いゲストユーザー #{old_guests.count} 件を削除しました"
    else
      puts '削除対象の古いゲストユーザーはありません'
    end

    puts '=== クリーンアップ完了 ==='
  end

  desc 'ゲストデータを完全リセット'
  task reset_all: :environment do
    puts '=== ゲストデータの完全リセットを開始 ==='

    # 全ゲストユーザーを削除
    guest_users = User.where('email LIKE ?', 'guest_%@example.com')

    if guest_users.any?
      puts "全ゲストユーザー #{guest_users.count} 件を削除中..."
      guest_users.each(&:destroy!)
      puts '全ゲストユーザーを削除しました'
    end

    # ゲスト企業データをリセット
    puts 'ゲスト企業データをリセット中...'
    Rake::Task['guest:reset'].invoke
    Rake::Task['guest:setup'].invoke
    Rake::Task['guest:sample_data'].invoke

    puts '=== 完全リセット完了 ==='
  end

  desc 'ゲスト企業のデータをリセット（ユーザーは保持）'
  task reset_company_data: :environment do
    puts '=== ゲスト企業データのリセットを開始 ==='

    # より安全な識別: メールアドレスと名前の両方で確認
    guest_company = Company.find_by(name: 'ゲスト企業', email: 'guest@example.com')

    # 追加の安全チェック: ゲスト企業の特徴を確認
    unless guest_company&.timezone == 'Tokyo' && guest_company&.phone == '03-1234-5678'
      puts '警告: ゲスト企業の識別に失敗しました。本登録企業の可能性があります。'
      puts "対象企業: #{guest_company&.name} (#{guest_company&.email})"
      puts '処理を中断します。'
      return
    end

    if guest_company
      puts 'ゲスト企業のデータをリセット中...'

      # 関連データを順番に削除
      puts '在庫移動履歴を削除中...'
      guest_company.stock_movements.destroy_all

      puts '物品を削除中...'
      guest_company.items.destroy_all

      puts 'カテゴリを削除中...'
      guest_company.categories.destroy_all

      puts '場所を削除中...'
      guest_company.locations.destroy_all

      puts '仕入先を削除中...'
      guest_company.suppliers.destroy_all

      puts '新しいサンプルデータを作成中...'
      Rake::Task['guest:sample_data'].invoke

      puts 'ゲスト企業データのリセットが完了しました'
    else
      puts "ゲスト企業が見つかりません。先に 'rails guest:setup' を実行してください。"
    end

    puts '=== ゲスト企業データリセット完了 ==='
  end

  desc 'ゲスト企業のデータを完全リセット（ユーザーも削除）'
  task reset_all_with_users: :environment do
    puts '=== ゲストデータの完全リセットを開始 ==='

    # 全ゲストユーザーを削除
    guest_users = User.where('email LIKE ?', 'guest_%@example.com')

    if guest_users.any?
      puts "全ゲストユーザー #{guest_users.count} 件を削除中..."
      guest_users.each(&:destroy!)
      puts '全ゲストユーザーを削除しました'
    end

    # ゲスト企業データを完全リセット
    puts 'ゲスト企業データを完全リセット中...'
    Rake::Task['guest:reset'].invoke
    Rake::Task['guest:setup'].invoke
    Rake::Task['guest:sample_data'].invoke

    puts '=== 完全リセット完了 ==='
  end

  desc 'ゲストデータの統計情報を表示'
  task stats: :environment do
    puts '=== ゲストデータの統計情報 ==='

    # ゲスト企業の数（より安全な識別）
    guest_companies = Company.where(name: 'ゲスト企業', email: 'guest@example.com')
    puts "ゲスト企業数: #{guest_companies.count}"

    # ゲストユーザーの数
    guest_users = User.where('email LIKE ?', 'guest_%@example.com')
    puts "ゲストユーザー数: #{guest_users.count}"

    # 古いゲストユーザーの数（1時間以上前）
    old_guests = User.where('email LIKE ? AND created_at < ?', 'guest_%@example.com', 1.hour.ago)
    puts "古いゲストユーザー数（1時間以上前）: #{old_guests.count}"

    # ゲスト企業のデータ統計
    if guest_companies.any?
      company = guest_companies.first
      puts '--- ゲスト企業のデータ統計 ---'
      puts "物品数: #{company.items.count}"
      puts "在庫移動数: #{company.stock_movements.count}"
      puts "カテゴリ数: #{company.categories.count}"
      puts "場所数: #{company.locations.count}"
      puts "仕入先数: #{company.suppliers.count}"

      # データの最終更新日時
      puts '--- データの最終更新日時 ---'
      puts "企業作成日: #{company.created_at}"
      puts "最新在庫移動: #{company.stock_movements.maximum(:created_at) || 'なし'}"
      puts "最新物品: #{company.items.maximum(:created_at) || 'なし'}"
    end

    puts '=== 統計情報表示完了 ==='
  end
end
