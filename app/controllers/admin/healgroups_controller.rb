# frozen_string_literal: true

module Admin
  class Admin::HealgroupsController < BaseController
    include ChartHelper

    before_action :set_admin_healgroup, only: [:show, :edit, :update, :destroy, :group_activity]
    before_action :set_admin_healgroup_users, :group_activity_line_chart, :group_activity_multi_line_chart, only: [:show]
    before_action :get_heal_group_users, only: [:update]

    # GET /admin/healgroups
    def index
      authorize Admin::Healgroup, :index?
      @admin_healgroups = Admin::Healgroup.all
    end

    # GET /admin/healgroups/1
    def show
      authorize @admin_healgroup, :show?
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
        update_groups_users!
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

    def group_activity
      @ahoy_events_all = Ahoy::Event.where(user_id: User.where(heal_group_name: @admin_healgroup.name))
      @ahoy_events_multi_data = {}
      @ahoy_events_multi_data = if params[:verbose]
                                  export_multi_line_engagement_chart_verbose(@ahoy_events_all)
                                else
                                  export_multi_line_engagement_chart(@ahoy_events_all)
                                end
      render json: { heal_group_name: @admin_healgroup.name, data_sets: @ahoy_events_multi_data }
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

    def set_admin_healgroup_users
      @admin_healgroup_accounts = Account.joins("INNER JOIN users ON users.account_id = accounts.id AND users.heal_group_name = '#{Admin::Healgroup.find(params[:id]).name}'")
    end

    def group_activity_line_chart
      @ahoy_events = Ahoy::Event.where(user_id: User.where(heal_group_name: @admin_healgroup.name))
      @ahoy_events_data = render_single_line_engagement_chart(@ahoy_events)
    end

    def group_activity_multi_line_chart
      @ahoy_events_all = Ahoy::Event.where(user_id: User.where(heal_group_name: @admin_healgroup.name))
      @ahoy_events_multi_data = render_multi_line_engagement_chart(@ahoy_events_all)
    end

    def get_heal_group_users
      @old_healgroup_name = @admin_healgroup.name
      pp " OLD NAME #{@old_healgroup_name}"
    end

    def update_groups_users!
      User.where(heal_group_name: @old_healgroup_name).update(heal_group_name: @admin_healgroup.name)
    end
  end
end
