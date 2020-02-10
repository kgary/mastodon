# frozen_string_literal: true

module Admin
  class RolesController < BaseController
    before_action :set_user

    def promote
      authorize @user, :promote?
      @user.promote!
      py_script = Rails.root.join('bridgesModFollow.py')
      res = `python3 #{py_script} '{"id": "#{@user.account_id}", "auth_token": "#{params[:authenticity_token]}"}'`
      log_action :promote, @user
      redirect_to admin_account_path(@user.account_id)
    end

    def demote
      authorize @user, :demote?
      @user.demote!
      log_action :demote, @user
      redirect_to admin_account_path(@user.account_id)
    end
  end
end
