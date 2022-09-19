# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2022 Liane Hampe <liaham@xmera.de>, xmera.
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

# require_relative 'base_presenter'

module RedmineDashboards
  ##
  # Prepares all issue query components to be ready for rendering.
  #
  class IssueQueryPresenter < AdvancedPluginHelper::BasePresenter
    presents :query

    def dashboard_query_list_block_title(query_block, project)
      title = []
      title << query.project if project.nil? && query.project
      title << query_block[:label].call

      title << if query_block[:with_project]
                 link_to query.name, send(query_block[:link_helper], project, query.as_params)
               else
                 link_to query.name, send(query_block[:link_helper], query.as_params)
               end

      safe_join title, RedmineDashboards::SEPARATOR
    end

    def dashboard_query_list_block_alerts(dashboard, block_object)
      return if dashboard.visibility == Dashboard::VISIBILITY_PRIVATE

      title = if query.visibility == Query::VISIBILITY_PRIVATE
                l :alert_only_visible_by_yourself
              elsif block_object.key?(:admin_only) && block_object[:admin_only]
                l :alert_only_visible_by_admins
              end

      return unless title

      content_tag :div, '', title: title, class: 'icon-only icon-warning attention', style: 'display: inline-block'
    end
  end
end
