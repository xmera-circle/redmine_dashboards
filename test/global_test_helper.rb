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

module RedmineDashboards
  module GlobalTestHelper
    def find_or_create_block(klass)
      klass.instance
    end

    def assert_select_td_column(column_name)
      c = column_name.to_s
                     .gsub('issue.cf', 'issue_cf')
                     .gsub('project.cf', 'project_cf')
                     .gsub('user.cf', 'user_cf')
                     .tr('.', '-')

      assert_select "td.#{c}"
    end

    def with_dashboard_settings(settings, &_block)
      change_dashboard_settings settings
      yield
    ensure
      restore_dashboard_settings
    end

    def change_dashboard_settings(settings)
      @saved_settings = Setting.plugin_redmine_dashboards.dup
      new_settings = Setting.plugin_redmine_dashboards.dup
      settings.each do |key, value|
        new_settings[key] = value
      end
      Setting.plugin_redmine_dashboards = new_settings
    end

    def restore_dashboard_settings
      if @saved_settings
        Setting.plugin_redmine_dashboards = @saved_settings
      else
        Rails.logger.warn 'warning: restore_dashboard_settings could not restore settings'
      end
    end

    def assert_query_sort_order(table_css, column, action: nil)
      action = :index if action.blank?
      column = column.to_s
      column_css = column.tr '_', '-'

      get action,
          params: { sort: "#{column}:asc", c: [column] }

      assert_response :success
      assert_select "table.list.#{table_css}.sort-by-#{column_css}.sort-asc"

      get action,
          params: { sort: "#{column}:desc", c: [column] }

      assert_response :success
      assert_select "table.list.#{table_css}.sort-by-#{column_css}.sort-desc"
    end

    def assert_dashboard_query_blocks(blocks = [])
      blocks.each do |attrs|
        attrs[:user_id]
        @request.session[:user_id] = attrs[:user_id].presence || 2
        get attrs[:action].presence || :show,
            params: { dashboard_id: attrs[:dashboard_id],
                      block_id: attrs[:block_id],
                      project_id: attrs[:project],
                      format: 'js' }
        assert_response :success, "assert_response for #{attrs[:block_id]}"
        assert response.body.presence, "response.body missing for #{attrs[:block_id]}"
        assert_select "table.list.#{attrs[:entities_class]}"
      end
    end
  end
end
