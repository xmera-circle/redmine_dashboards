# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2016 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/additionals>.
#
# Copyright (C) 2021 - 2022 Liane Hampe <liaham@xmera.de>, xmera.
#
# This plugin program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

class DashboardsController < ApplicationController
  menu_item :dashboards

  before_action :find_dashboard, except: %i[index new create]
  before_action :find_optional_project, only: %i[new create index]
  before_action :authorize_global

  accept_atom_auth :index, :show
  accept_api_auth :index, :show, :create, :update, :destroy

  rescue_from Query::StatementInvalid, with: :query_statement_invalid

  helper :queries
  helper :issues
  helper :activities
  helper :watchers
  helper :dashboards
  helper :dashboards_routes
  helper :dashboards_queries
  helper :dashboards_settings

  include DashboardsQueriesHelper
  include DashboardsRoutesHelper
  include QueriesHelper
  include WatchersHelper
  include SortHelper

  def index
    case params[:format]
    when 'xml', 'json'
      @offset, @limit = api_offset_and_limit
    else
      @limit = per_page_option
    end

    scope = Dashboard.visible
    @query_count = scope.count
    @query_pages = Paginator.new @query_count, @limit, params['page']
    @dashboards = scope.sorted
                       .limit(@limit)
                       .offset(@offset)
                       .to_a

    respond_to do |format|
      format.html { render_error status: 406 }
      format.api
    end
  end

  def show
    respond_to do |format|
      format.html { head :not_acceptable }
      format.js if request.xhr?
      format.api
    end
  end

  def new
    @dashboard = Dashboard.new(project: @project,
                               user: User.current)
    @dashboard.dashboard_type = assign_dashboard_type
    @allowed_projects = @dashboard.allowed_target_projects
  end

  def create
    @dashboard = Dashboard.new(user: User.current)
    @dashboard.safe_attributes = params[:dashboard]
    @dashboard.dashboard_type = assign_dashboard_type
    @dashboard.role_ids = params[:dashboard][:role_ids] if params[:dashboard].present?

    @allowed_projects = @dashboard.allowed_target_projects

    if @dashboard.save
      flash[:notice] = l :notice_successful_create

      respond_to do |format|
        format.html { redirect_to dashboard_link_path(@dashboard) }
        format.api  do
          render action: 'show', status: :created, location: dashboard_url(@dashboard, project_id: @project)
        end
      end
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.api  { render_validation_errors @dashboard }
      end
    end
  end

  def edit
    return render_403 unless @dashboard.editable_by? User.current

    respond_to do |format|
      format.html
      format.api
    end
  end

  def update
    return render_403 unless @dashboard.editable_by? User.current

    @dashboard.safe_attributes = params[:dashboard]
    @dashboard.role_ids = params[:dashboard][:role_ids] if params[:dashboard].present?

    if @dashboard.save
      flash[:notice] = l :notice_successful_update
      respond_to do |format|
        format.html { redirect_to dashboard_link_path(@dashboard) }
        format.api  { head :ok }
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.api  { render_validation_errors @dashboard }
      end
    end
  end

  def destroy
    return render_403 unless @dashboard.destroyable_by? User.current

    begin
      @dashboard.destroy
      flash[:notice] = l :notice_successful_delete
      respond_to do |format|
        format.html { redirect_to home_path }
        format.api  { head :ok }
      end
    rescue ActiveRecord::RecordNotDestroyed
      flash[:error] = l :error_remove_db_entry
      redirect_to dashboard_path(@dashboard)
    end
  end

  def query_statement_invalid(exception)
    logger&.error "Query::StatementInvalid: #{exception.message}"
    session.delete dashboard_query_session_key('dashboard')
    render_error l(:error_query_statement_invalid)
  end

  def update_layout_setting
    block_settings = params[:settings] || {}
    block_settings.each do |block_id, settings|
      @dashboard.update_block_settings block_id, settings.to_unsafe_hash
    end
    @dashboard.save
    @updated_blocks = block_settings.keys
  end

  ##
  # Adds a new block on top of the page
  #
  # @params params[:block_id] Id of the block to add, i.e., button__1
  #
  def add_block
    @block_id = params[:block_id]
    added = @dashboard.add_block @block_id
    saved = @dashboard.save
    if added && saved
      respond_to do |format|
        format.html { redirect_to dashboard_link_path(@dashboard) }
        format.js
      end
    else
      flash[:error] = "#{@dashboard.name}: #{@dashboard.errors.full_messages.join(', ')}"
      redirect_to dashboard_link_path(@dashboard)
    end
  end

  ##
  # Removes the given block from the page
  #
  # @params params[:block_id] Id of the block to add, i.e., button__1
  #
  def remove_block
    @block_id = params[:block_id]
    @dashboard.remove_block @block_id
    @dashboard.save
    respond_to do |format|
      format.html { redirect_to dashboard_link_path(@dashboard) }
      format.js
    end
  end

  # Change blocks order
  # params[:group] : group to order (top, left or right)
  # params[:block_ids] : array of block ids of the group
  def order_blocks
    @dashboard.order_blocks params[:group], params[:block_ids]
    @dashboard.save
    @block_ids = params[:block_ids]
  end

  private

  def assign_dashboard_type
    if params['dashboard_type'].present?
      params['dashboard_type']
    elsif params['dashboard'].present? && params['dashboard']['dashboard_type'].present?
      params['dashboard']['dashboard_type']
    elsif @project.nil?
      DashboardContentWelcome::TYPE_NAME
    else
      DashboardContentProject::TYPE_NAME
    end
  end

  def find_dashboard
    @dashboard = Dashboard.find params[:id]
    raise ::Unauthorized unless @dashboard.visible?

    @project = @dashboard.project
    @can_edit = @dashboard&.editable?
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
