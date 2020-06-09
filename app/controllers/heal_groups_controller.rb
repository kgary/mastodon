# frozen_string_literal: true

class HealGroupsController < ApplicationController
  before_action :require_admin!, only: [:index, :show, :edit, :update, :destroy]
  before_action :set_heal_group, only: [:show, :edit, :update, :destroy]

  # GET /heal_groups
  def index
    @heal_groups = HealGroup.all
  end

  # GET /heal_groups/1
  def show; end

  # GET /heal_groups/new
  def new
    @heal_group = HealGroup.new
  end

  # GET /heal_groups/1/edit
  def edit; end

  # POST /heal_groups
  def create
    @heal_group = HealGroup.new(name: heal_group_params[:name], start_date: Date.parse("#{heal_group_params['start_date(3i)']}-#{heal_group_params['start_date(1i)']}-#{heal_group_params['start_date(2i)']}"))

    if @heal_group.save
      redirect_to @heal_group, notice: 'Heal group was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /heal_groups/1
  def update
    if @heal_group.update(name: heal_group_params[:name], start_date: Date.parse("#{heal_group_params['start_date(3i)']}-#{heal_group_params['start_date(1i)']}-#{heal_group_params['start_date(2i)']}"))
      redirect_to @heal_group, notice: 'Heal group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /heal_groups/1
  def destroy
    @heal_group.destroy
    redirect_to heal_groups_url, notice: 'Heal group was successfully destroyed.'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_heal_group
      @heal_group = HealGroup.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def heal_group_params
      params.fetch(:heal_group, {})
    end
end
