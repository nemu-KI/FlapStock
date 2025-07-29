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

  class Scope < ApplicationPolicy::Scope
    def resolve
      return User.none unless user.admin?
      scope.where(company: user.company)
    end
  end
end
