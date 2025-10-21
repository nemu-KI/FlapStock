# frozen_string_literal: true

# UserPolicy
class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? && same_company?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? && same_company?
  end

  def destroy?
    user.admin? && same_company? && record != user
  end

  def change_role?
    user.admin? && same_company? && record != user
  end

  def update_display?
    # 自分自身の表示設定のみ更新可能。管理者は他ユーザーも可にするなら拡張
    user.admin? || record.id == user.id
  end

  def update_user?
    user == record # ユーザー自身のみが自身のプロフィールやパスワードを更新できる
  end

  # UserPolicy::Scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      return User.none unless user.admin?

      scope.where(company: user.company)
    end
  end

  private

  def same_company?
    record.company_id == user.company_id
  end
end
