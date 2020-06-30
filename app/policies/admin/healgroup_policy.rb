# frozen_string_literal: true

class Admin::HealgroupPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    staff?
  end

  def create?
    admin?
  end

  def destroy?
    admin?
  end

  def update?
    admin?
  end

  def edit?
    admin?
  end

  def new?
    admin?
  end
end
