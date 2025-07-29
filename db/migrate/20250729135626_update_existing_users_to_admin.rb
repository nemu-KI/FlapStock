class UpdateExistingUsersToAdmin < ActiveRecord::Migration[7.1]
  def up
    # 既存のユーザーをadminに設定（role = 2）
    User.update_all(role: 2)
  end

  def down
    # ロールバック時はstaffに設定（role = 0）
    User.update_all(role: 0)
  end
end
