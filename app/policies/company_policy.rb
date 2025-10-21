# frozen_string_literal: true

# CompanyPolicy
class CompanyPolicy < ApplicationPolicy
  def show?
    user.admin? && same_company?
  end

  def edit?
    user.admin? && same_company?
  end

  def update?
    user.admin? && same_company?
  end

  def manage_users?
    user.admin? && same_company?
  end

  # CompanyPolicy::Scope
  class Scope < ApplicationPolicy::Scope
    def resolve
      return Company.none unless user.admin?

      scope.where(id: user.company_id)
    end
  end

  private

  def same_company?
    record.id == user.company_id
  end
end
