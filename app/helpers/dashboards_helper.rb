# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2016 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/additionals>.
#
# Copyright (C) 2021-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

module DashboardsHelper
  def dashboard_async_cache(dashboard, block_id, async, settings, &content_block)
    cache render_async_cache_key(dashboard_async_blocks_path(dashboard.async_params(block_id, async, settings))),
          expires_in: async[:cache_expires_in] || DashboardContent::RENDER_ASYNC_CACHE_EXPIRES_IN,
          skip_digest: true, &content_block
  end

  # candidate for a service_object?
  def dashboard_async_required_settings?(settings, async)
    return true if async[:required_settings].blank?
    return false if settings.blank?

    async[:required_settings].each do |required_setting|
      return false if settings.exclude?(required_setting) || settings[required_setting].blank?
    end

    true
  end

  # candidate for a service object
  def dashboard_sidebar?(params)
    enabled = params['enable_sidebar']
    return false if enabled.blank?

    RedmineDashboards.true? enabled
  end

  # Renders a single block content - candidate for a service object
  def render_dashboard_block_content(block_id, block_object, dashboard, overwritten_settings = {})
    settings = dashboard.layout_settings(block_id)
    settings = settings.merge(overwritten_settings) if overwritten_settings.present?
    partial = block_object[:partial]
    partial_locals = build_dashboard_partial_locals block_id, block_object, settings, dashboard

    if block_object[:query_block] || block_object[:async]
      render partial: 'dashboards/blocks/async', locals: partial_locals
    elsif partial
      begin
        render partial: partial, locals: partial_locals
      rescue ActionView::MissingTemplate
        Rails.logger.warn "Partial \"#{partial}\" missing for block " \
                          "\"#{block_id}\" found in #{dashboard.name} (id=#{dashboard.id})"
        nil
      end
    else
      # Required for legacy blocks only!
      block_object.send "render_#{block_object[:type]}_block", block_id, settings, dashboard
    end
  end

  # candidate for service object
  def build_dashboard_partial_locals(block_id, block_object, settings, dashboard)
    partial = BlockPartial.new(block: { id: block_id, object: block_object },
                               settings: settings,
                               dashboard: dashboard,
                               params: params)
    partial.locals
  end

  # issue counter and query list - candidate for a service/query object
  def options_for_query_select(klass, project, selected = nil)
    tag.option + options_from_collection_for_select(queries(klass, project), :id, :name, selected)
  end

  # issue counter and query list - candidate for a service/query object
  def grouped_options_for_query_select(klass, project, selected = nil)
    all_queries = queries(klass, project)
    group = { "#{l(:label_my_queries)}": all_queries.select(&:is_private?).pluck(:name, :id),
              "#{l(:label_query_plural)}": all_queries.reject(&:is_private?).pluck(:name, :id) }

    tag.option + grouped_options_for_select(group.to_a, selected)
  end

  private

  # candidate for a service/query object
  ##
  # sidebar_queries cannot be used because descendant classes are included
  # this changes on class loading
  # queries = klass.visible.global_or_on_project(@project).sorted.to_a
  #
  def queries(klass, project)
    klass
      .visible
      .global_or_on_project(project)
      .where(type: klass.to_s)
      .sorted.to_a
  end

  # candidate for a service object
  def resently_used_dashboard_save(dashboard, project = nil)
    user = User.current
    dashboard_type = dashboard.dashboard_type
    recently_id = user.pref.recently_used_dashboard dashboard_type, project
    return if recently_id == dashboard.id || user.anonymous?

    user.pref.recently_used_dashboards[dashboard_type] = dashboard.id
    user.pref.save
  end

  ##
  # Copied from Redmine ReportsHelper module
  #
  def aggregate(data, criteria)
    a = 0
    data&.each do |row|
      match = 1
      criteria&.each do |k, v|
        next if (row[k].to_s == v.to_s) ||
                (k == 'closed' &&
                  (v.zero? ? ['f', false] : ['t', true]).include?(row[k]))

        match = 0
      end
      a += row['total'].to_i if match == 1
    end
    a
  end
end
