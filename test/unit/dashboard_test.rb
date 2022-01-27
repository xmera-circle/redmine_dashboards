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

require File.expand_path '../test_helper', __dir__

class DashboardTest < RedmineDashboards::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles,
           :trackers, :projects_trackers,
           :enabled_modules,
           :issue_statuses, :issue_categories, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values,
           :dashboards, :dashboard_roles

  def setup
    prepare_tests
    User.current = users :users_002
  end

  def test_create_welcome_dashboard
    dashboard = Dashboard.new name: 'my welcome dashboard',
                              dashboard_type: DashboardContentWelcome::TYPE_NAME,
                              author_id: 2

    assert_save dashboard
  end

  def test_do_not_create_dashboard_for_role_without_roles
    dashboard = Dashboard.new name: 'dashboard for roles',
                              dashboard_type: DashboardContentWelcome::TYPE_NAME,
                              author_id: 2,
                              visibility: Dashboard::VISIBILITY_ROLES

    assert_not dashboard.valid?
  end

  def test_create_dashboard_with_roles
    dashboard = Dashboard.new name: 'dashboard for roles',
                              dashboard_type: DashboardContentWelcome::TYPE_NAME,
                              author_id: 2,
                              visibility: Dashboard::VISIBILITY_ROLES,
                              roles: Role.where(id: [1, 3]).to_a

    assert_save dashboard
    dashboard.reload

    assert_equal [1, 3], dashboard.role_ids.sort
  end

  def test_create_dashboard_with_unused_role_should_visible_for_author
    used_role = Role.generate!
    dashboard = Dashboard.new name: 'dashboard for unused role',
                              dashboard_type: DashboardContentWelcome::TYPE_NAME,
                              author_id: 2,
                              visibility: Dashboard::VISIBILITY_ROLES,
                              roles: [used_role]
    assert_save dashboard
    dashboard.reload

    assert_equal [used_role.id], dashboard.role_ids
    assert dashboard.visible?
  end

  def test_system_default_welcome_should_exist
    assert_equal 1, Dashboard.welcome_only.where(system_default: true).count
  end

  def test_change_system_default_welcome_without_set_system_default
    dashboard = Dashboard.new dashboard_type: DashboardContentWelcome::TYPE_NAME,
                              name: 'WelcomeTest',
                              system_default: true,
                              author: User.current,
                              visibility: 2
    assert_save dashboard

    assert dashboard.system_default
    assert_equal 2, dashboard.visibility
  end

  def test_system_default_welcome_allowed_only_once
    assert Dashboard.create!(dashboard_type: DashboardContentWelcome::TYPE_NAME,
                             name: 'WelcomeTest',
                             system_default: true,
                             author: User.current,
                             visibility: 2)

    assert_equal 1, Dashboard.welcome_only.where(system_default: true).count
  end

  def test_system_default_welcome_requires_public_visibility
    dashboard = Dashboard.create!(dashboard_type: DashboardContentWelcome::TYPE_NAME,
                                  name: 'WelcomeTest public',
                                  system_default: true,
                                  author: User.current,
                                  visibility: 2)

    assert dashboard.valid?

    dashboard.visibility = 0
    assert_not dashboard.valid?
  end

  def test_system_default_welcome_should_not_be_deletable
    assert_raise Exception do
      Dashboard.welcome_only
               .where(system_default: true)
               .destroy_all
    end
  end

  def test_dashboard_welcome_scope
    assert_equal 4, Dashboard.visible.welcome_only.count
  end

  def test_destroy_dashboard_without_roles
    dashboard = dashboards :private_welcome2
    assert dashboard.roles.none?
    assert dashboard.destroyable_by? users(:users_002)
    assert_difference 'Dashboard.count', -1 do
      assert dashboard.destroy
    end
  end

  def test_create_dashboard_roles_relation
    dashboard = dashboards :welcome_for_roles
    assert_equal 2, dashboard.roles.count

    relation = DashboardRole.new role_id: 3, dashboard_id: dashboard.id
    assert_save relation

    dashboard.reload
    assert_equal 3, dashboard.roles.count
  end

  def test_create_dashboard_roles_relation_with_autosave
    dashboard = dashboards :welcome_for_roles
    assert_equal 2, dashboard.roles.count

    dashboard.roles << Role.generate!
    assert_save dashboard
    dashboard.reload
    assert_equal 3, dashboard.roles.count
  end

  def test_destroy_dashboard_with_roles
    User.current = users :users_001

    # change system default
    dashboard2 = dashboards :public_welcome
    dashboard2.system_default = true
    assert_save dashboard2

    dashboard = dashboards :welcome_for_roles
    dashboard.reload

    assert dashboard.roles.any?
    assert dashboard.destroyable_by? users(:users_001)
    assert_difference 'Dashboard.count', -1 do
      assert_difference 'DashboardRole.count', -2 do
        assert_no_difference 'Role.count' do
          assert dashboard.destroy
        end
      end
    end
  end

  def test_disable_welcome_system_default_on_system_default_dashboard_should_not_possible
    dashboard = dashboards :system_default_welcome
    assert dashboard.system_default

    dashboard.system_default = false
    assert_raise Dashboard::SystemDefaultChangeException do
      dashboard.save!
    end
  end

  def test_dashboard_name_should_strip_spaces
    dashboard = dashboards :system_default_welcome
    dashboard.name = ' new name '
    assert_save dashboard

    dashboard.reload
    assert_equal 'new name', dashboard.name
  end
end
