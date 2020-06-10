# frozen_string_literal: true

module Admin
  class Admin::HealgroupsController < BaseController
    before_action :set_admin_healgroup, only: [:show, :edit, :update, :destroy]

    # GET /admin/healgroups
    def index
      authorize Admin::Healgroup, :index?
      @admin_healgroups = Admin::Healgroup.all
    end

    # GET /admin/healgroups/1
    def show
      authorize @admin_healgroup, :show?
      #@admin_healgroup_users = User.where(heal_group_name: Admin::Healgroup.find(params[:id]).name)
      @admin_healgroup_users = Account.joins("INNER JOIN users ON users.account_id = accounts.id AND users.heal_group_name = '#{Admin::Healgroup.find(params[:id]).name}'")
    end

    # GET /admin/healgroups/new
    def new
      authorize Admin::Healgroup, :new?
      @admin_healgroup = Admin::Healgroup.new
    end

    # GET /admin/healgroups/1/edit
    def edit
      authorize @admin_healgroup, :edit?
    end

    # POST /admin/healgroups
    def create
      authorize Admin::Healgroup, :create?
      @admin_healgroup = Admin::Healgroup.new(admin_healgroup_params)

      if @admin_healgroup.save
        redirect_to @admin_healgroup, notice: 'Healgroup was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /admin/healgroups/1
    def update
      authorize @admin_healgroup, :update?
      if @admin_healgroup.update(admin_healgroup_params)
        redirect_to @admin_healgroup, notice: 'Healgroup was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin/healgroups/1
    def destroy
      authorize @admin_healgroup, :destroy?
      @admin_healgroup.destroy!
      log_action :destroy, @admin_healgroup
      redirect_to admin_healgroups_url, notice: 'Healgroup was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_admin_healgroup
        @admin_healgroup = Admin::Healgroup.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def admin_healgroup_params
        params.require(:admin_healgroup).permit(:name, :start_date)
      end
  end
end
