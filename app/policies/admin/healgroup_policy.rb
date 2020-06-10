# frozen_string_literal: true

class Admin::HealgroupPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
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
