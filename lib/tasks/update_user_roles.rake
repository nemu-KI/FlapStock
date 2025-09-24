# frozen_string_literal: true

namespace :users do
  desc '既存ユーザーの権限をadminに更新（MVPリリース期間中）'
  task update_to_admin: :environment do
    puts '既存ユーザーの権限をadminに更新しています...'

    users = User.where.not(role: :admin)
    count = users.count

    if count.zero?
      puts '更新が必要なユーザーはいません。'
    else
      users.update_all(role: :admin)
      puts "#{count}人のユーザーの権限をadminに更新しました。"
    end

    puts '現在のユーザー権限一覧:'
    User.all.each do |user|
      puts "- #{user.email}: #{user.role}"
    end
  end
end
