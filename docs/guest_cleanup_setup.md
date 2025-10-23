# ゲストデータ自動クリーンアップ設定

## 概要
ゲストユーザーのデータを自動的にクリーンアップするための設定方法です。

## 利用可能なRakeタスク

### 1. 古いゲストデータのクリーンアップ
```bash
# 1時間以上古いゲストユーザーを削除
rails guest:cleanup
```

### 2. ゲスト企業データのリセット（ユーザーは保持）
```bash
# ゲスト企業の物品・マスターデータ・履歴をリセット（ユーザーは保持）
rails guest:reset_company_data
```

### 3. ゲストデータの完全リセット
```bash
# 全ゲストユーザーを削除し、ゲスト企業データをリセット
rails guest:reset_all_with_users
```

### 4. ゲストデータの統計情報表示
```bash
# 現在のゲストデータの統計を表示
rails guest:stats
```

## 定期実行の設定

### cronを使用した定期実行

#### 1. 毎時クリーンアップ（推奨）
```bash
# crontab -e で以下を追加
0 * * * * cd /path/to/your/app && bundle exec rails guest:cleanup
```

#### 2. 毎日深夜にゲスト企業データをリセット
```bash
# 毎日午前2時にゲスト企業データをリセット（ユーザーは保持）
0 2 * * * cd /path/to/your/app && bundle exec rails guest:reset_company_data
```

#### 3. 週次完全リセット
```bash
# 毎週日曜日の午前3時に完全リセット
0 3 * * 0 cd /path/to/your/app && bundle exec rails guest:reset_all_with_users
```

#### 3. 週次統計レポート
```bash
# 毎週月曜日の午前9時に統計レポートをメール送信
0 9 * * 1 cd /path/to/your/app && bundle exec rails guest:stats | mail -s "Guest Data Stats" admin@example.com
```

### Docker環境での設定

#### docker-compose.ymlに追加
```yaml
services:
  # 既存のwebサービス...
  
  guest-cleanup:
    build: .
    command: bundle exec rails guest:cleanup
    volumes:
      - .:/app
    depends_on:
      - db
    environment:
      - RAILS_ENV=production
```

#### 定期実行用のcronコンテナ
```yaml
services:
  cron:
    build: .
    volumes:
      - .:/app
    command: |
      sh -c "
        echo '0 * * * * cd /app && bundle exec rails guest:cleanup' | crontab -
        crond -f
      "
    depends_on:
      - db
```

## 監視とアラート

### ログ監視
```bash
# クリーンアップのログを監視
tail -f log/production.log | grep "ゲストデータのクリーンアップ"
```

### 統計レポートの自動送信
```ruby
# lib/tasks/guest_report.rake
namespace :guest do
  desc 'ゲストデータの週次レポートを送信'
  task weekly_report: :environment do
    stats = `rails guest:stats`
    # メール送信処理
    AdminMailer.guest_data_report(stats).deliver_now
  end
end
```

## 注意事項

1. **本番環境での実行**: 必ず本番環境でテストしてから定期実行を設定してください
2. **バックアップ**: 重要なデータは事前にバックアップを取ってください
3. **ログ監視**: 定期実行のログを監視して、正常に動作していることを確認してください
4. **リソース監視**: 大量のデータ削除時はサーバーリソースを監視してください
5. **企業名の重複**: 本登録企業が「ゲスト企業」という名前を使用している場合は、自動クリーンアップが実行されません（安全機能）

## セキュリティ機能

### 多重安全チェック
- **名前とメールアドレス**: `name: 'ゲスト企業'` AND `email: 'guest@example.com'`
- **追加属性チェック**: `timezone: 'Tokyo'` AND `phone: '03-1234-5678'`
- **失敗時の中断**: 本登録企業の可能性がある場合は処理を中断

## トラブルシューティング

### よくある問題

1. **権限エラー**: cronの実行ユーザーに適切な権限があることを確認
2. **パスエラー**: 絶対パスを使用してパスの問題を回避
3. **環境変数**: 本番環境の環境変数が正しく設定されていることを確認

### デバッグ方法

```bash
# 手動実行でテスト
cd /path/to/your/app
bundle exec rails guest:stats
bundle exec rails guest:cleanup

# ログを確認
tail -f log/production.log
```
