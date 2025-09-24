# frozen_string_literal: true

# StockMovementPolicy
class StockMovementPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  # StockMovementPolicy::Scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.present? && user.company.present?
        scope.where(company: user.company)
      else
        scope.none
      end
    end
  end

  def index?
    user.present?
  end

  def show?
    user.present? && same_company?
  end

  def create?
    user.present? && (user.manager? || user.admin?)
  end

  def update?
    user.present? && same_company? && (user.manager? || user.admin?)
  end

  def destroy?
    user.present? && same_company? && user.admin?
  end

  private

  def same_company?
    record.company == user.company
  end
end
