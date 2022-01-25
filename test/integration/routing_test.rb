# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2016 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/RedmineDashboards>.
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

require File.expand_path '../../test_helper', __FILE__

class RoutingTest < Redmine::RoutingTest
  # def test_issue_assign_to_me
  #   should_route 'PUT /issues/1/assign_to_me' => 'additionals_assign_to_me#update', issue_id: '1'
  # end

  # def test_issue_change_status
  #   should_route 'PUT /issues/1/change_status' => 'additionals_change_status#update', issue_id: '1'
  # end

  # def test_help_macro
  #   should_route 'GET /help/macros' => 'additionals_macros#show'
  # end

  # def test_auto_completes
  #   should_route 'GET /auto_completes/fontawesome' => 'auto_completes#fontawesome'
  #   should_route 'GET /auto_completes/issue_assignee' => 'auto_completes#issue_assignee'
  #   should_route 'GET /auto_completes/global_users' => 'auto_completes#global_users'
  # end

  def test_dashboards
    should_route 'GET /dashboards.xml' => 'dashboards#index', format: 'xml'
    should_route 'GET /dashboards.json' => 'dashboards#index', format: 'json'

    should_route 'GET /dashboards/1.xml' => 'dashboards#show', id: '1', format: 'xml'
    should_route 'GET /dashboards/1.json' => 'dashboards#show', id: '1', format: 'json'
    should_route 'GET /dashboards/1/edit' => 'dashboards#edit', id: '1'
  end

  def test_dashboard_async_blocks
    should_route 'GET /dashboard_async_blocks' => 'dashboard_async_blocks#show'
  end
end
