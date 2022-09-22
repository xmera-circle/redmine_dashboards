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

require 'open-uri'

class DashboardAsyncBlocksController < ApplicationController
  before_action :find_dashboard
  before_action :find_block

  helper :dashboards_routes
  helper :dashboards_queries
  helper :queries
  helper :issues
  helper :activities
  helper :dashboards
  helper :calendars

  include DashboardsHelper

  rescue_from Query::StatementInvalid, with: :query_statement_invalid # is defined in DashboardsController
  rescue_from StandardError, with: :dashboard_with_invalid_block

  def show
    @settings[:sort] = params[:sort] if params[:sort].present?
    partial_locals = build_dashboard_partial_locals @block_id, @block_object, @settings, @dashboard

    respond_to do |format|
      format.js do
        render partial: partial_locals[:async][:partial],
               content_type: 'text/html',
               locals: partial_locals
      end
    end
  end

  # abuse create for query list sort order support
  def create
    return render_403 if params[:sort].blank?

    partial_locals = build_dashboard_partial_locals @block_id, @block_object, @settings, @dashboard
    partial_locals[:sort_options] = { sort: params[:sort] }

    respond_to do |format|
      format.js do
        render partial: 'update_order_by',
               locals: partial_locals
      end
    end
  end

  private

  def find_dashboard
    @dashboard = Dashboard.find params[:dashboard_id]
    raise ::Unauthorized unless @dashboard.visible?

    @project = @dashboard.project
    deny_access if @project.present? && !User.current.allowed_to?(:view_project, @project)
    @can_edit = @dashboard&.editable?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_block
    @block_id = params['block_id']
    @block_object = @dashboard.content.find_block @block_id
    render_404 if @block_id.blank?
    render_403 if @block_object.blank?

    @settings = @dashboard.layout_settings @block_id
  end

  def dashboard_with_invalid_block(exception)
    logger&.error "Invalid dashboard block for #{@block_id} (#{exception.class.name}): #{exception.message}"
    respond_to do |format|
      format.html do
        render template: 'dashboards/block_error', layout: false
      end
      format.any { head @status }
    end
  end
end
