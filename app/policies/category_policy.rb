# frozen_string_literal: true

# CategoryPolicy
class CategoryPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && same_company?
  end

  def create?
    user.manager? || user.admin?
  end

  def update?
    user.manager? || user.admin?
  end

  def destroy?
    user.admin?
  end

  # CategoryPolicy::Scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      return Category.none unless user.present?

      scope.where(company: user.company)
    end
  end
end
