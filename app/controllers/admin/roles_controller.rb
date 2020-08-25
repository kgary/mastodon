# frozen_string_literal: true

module Admin
  class RolesController < BaseController
    include HealFollowHelper
    before_action :set_user

    def promote
      authorize @user, :promote?
      @user.promote!
      # follow all
      group_follows!(@user)
      #py_script = Rails.root.join('bridgesModFollow.py')
      #res = `python3 #{py_script} '{"id": "#{params[:account_id]}", "auth_token": "#{params[:authenticity_token]}"}'`
      log_action :promote, @user
      redirect_to admin_account_path(@user.account_id)
    end

    def demote
      authorize @user, :demote?
      @user.demote!
      # unfollow non group members
      destroy_heal_follows!(@user)
      log_action :demote, @user
      redirect_to admin_account_path(@user.account_id)
    end
  end
end
