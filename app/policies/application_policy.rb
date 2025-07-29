# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    user.present? && same_company?
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    user.present? && same_company?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin? && same_company?
  end

  private

  def same_company?
    return true unless record.respond_to?(:company)
    record.company == user.company
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.none unless user.present?

      if scope.respond_to?(:where) && scope.respond_to?(:company)
        scope.where(company: user.company)
      else
        scope
      end
    end

    private

    attr_reader :user, :scope
  end
end
