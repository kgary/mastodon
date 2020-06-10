class Admin::HealgroupsController < ApplicationController
  before_action :set_admin_healgroup, only: [:show, :edit, :update, :destroy]

  # GET /admin/healgroups
  def index
    @admin_healgroups = Admin::Healgroup.all
  end

  # GET /admin/healgroups/1
  def show
  end

  # GET /admin/healgroups/new
  def new
    @admin_healgroup = Admin::Healgroup.new
  end

  # GET /admin/healgroups/1/edit
  def edit
  end

  # POST /admin/healgroups
  def create
    @admin_healgroup = Admin::Healgroup.new(admin_healgroup_params)

    if @admin_healgroup.save
      redirect_to @admin_healgroup, notice: 'Healgroup was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /admin/healgroups/1
  def update
    if @admin_healgroup.update(admin_healgroup_params)
      redirect_to @admin_healgroup, notice: 'Healgroup was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /admin/healgroups/1
  def destroy
    @admin_healgroup.destroy
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
