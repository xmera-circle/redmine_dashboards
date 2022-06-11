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

require File.expand_path '../../test_helper', __FILE__

class DashboardsControllerTest < RedmineDashboards::ControllerTest
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :dashboards, :dashboard_roles,
           :queries

  include CrudControllerBase

  def setup
    prepare_tests

    User.current = nil
    @user = users :users_002
    # manager = roles :roles_001
    # manager.add_permission! :manage_own_dashboards
    @user_without_permission = users :users_004

    @crud = { form: :dashboard,
              show_assert_response: 403,
              index_assert_response: 406,
              create_params: { name: 'tester board',
                               enable_sidebar: true,
                               dashboard_type: DashboardContentWelcome::TYPE_NAME,
                               author_id: @user.id },
              create_assert_equals: { name: 'tester board' },
              create_assert: %i[enable_sidebar],
              edit_assert_select: ['form#dashboard-form'],
              update_params: { name: 'changed',
                               enable_sidebar: true },
              update_assert_equals: { name: 'changed' },
              update_assert: %i[enable_sidebar],
              entity: dashboards(:private_welcome2),
              delete_redirect_to: home_url }
  end

  def test_should_not_edit_public_dashboard
    prepare_crud_test :edit
    @crud[:entity] = dashboards(:public_welcome)
    get :edit, params: { id: @crud[:entity].id }

    assert_response :forbidden
  end

  def test_should_edit_system_dashboard
    prepare_crud_test :edit
    @crud[:entity] = dashboards(:system_default_welcome)

    get :edit, params: { id: @crud[:entity].id }

    assert_response :success
  end
end
