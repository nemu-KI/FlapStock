# frozen_string_literal: true

# LocationPolicy
class LocationPolicy < ApplicationPolicy
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

  # LocationPolicy::Scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      return Location.none unless user.present?

      scope.where(company: user.company)
    end
  end
end
