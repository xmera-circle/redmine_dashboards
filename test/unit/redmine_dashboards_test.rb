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

class RedmineDashboardsTest < RedmineDashboards::TestCase
  # fixtures :projects, :users, :members, :member_roles, :roles,
  #          :trackers, :projects_trackers,
  #          :enabled_modules,
  #          :enumerations

  include Redmine::I18n

  def setup
    prepare_tests
  end

  def test_true
    assert RedmineDashboards.true? 1
    assert RedmineDashboards.true? true
    assert RedmineDashboards.true? 'true'
    assert RedmineDashboards.true? 'True'

    assert_not RedmineDashboards.true?(-1)
    assert_not RedmineDashboards.true? 0
    assert_not RedmineDashboards.true? '0'
    assert_not RedmineDashboards.true? 1000
    assert_not RedmineDashboards.true? false
    assert_not RedmineDashboards.true? 'false'
    assert_not RedmineDashboards.true? 'False'
    assert_not RedmineDashboards.true? 'yes'
    assert_not RedmineDashboards.true? ''
    assert_not RedmineDashboards.true? nil
    assert_not RedmineDashboards.true? 'unknown'
  end

  # def test_settings
  #   assert_raises NoMethodError do
  #     RedmineDashboards.settings[:open_external_urls]
  #   end
  # end

  # def test_setting
  #   assert_equal 'Don\'t forget to define acceptance criteria!',
  #                RedmineDashboards.setting(:new_ticket_message)
  #   assert RedmineDashboards.setting?(:open_external_urls)
  #   assert_nil RedmineDashboards.setting(:no_existing_key)
  # end

  # def test_setting_bool
  #   assert RedmineDashboards.setting?(:open_external_urls)
  #   assert_not RedmineDashboards.setting?(:add_go_to_top)
  # end

  # def test_load_macros
  #   macros = RedmineDashboards.load_macros

  #   assert macros.count.positive?
  #   assert(macros.detect { |macro| macro.include? 'fa_macro' })
  # end

  # def test_split_ids
  #   assert_equal [1, 2, 3], RedmineDashboards.split_ids('1, 2 , 3')
  #   assert_equal [3, 2], RedmineDashboards.split_ids('3, 2, 2')
  #   assert_equal [1, 2], RedmineDashboards.split_ids('1, 2 3')
  #   assert_equal [], RedmineDashboards.split_ids('')
  #   assert_equal [0], RedmineDashboards.split_ids('non-number')
  # end

  # def test_split_ids_with_ranges
  #   assert_equal [1, 2, 3, 4, 5], RedmineDashboards.split_ids('1, 2 , 3, 3 - 5')
  #   assert_equal [1, 2, 3, 4, 5], RedmineDashboards.split_ids('1, 2 , 3, 5 - 2')
  #   assert_equal [1, 2, 3], RedmineDashboards.split_ids('1, 2 , 3, 5 - 3 - 1')
  # end

  # def test_split_ids_with_restricted_large_range
  #   assert_equal [33_333, 33_334, 33_335, 33_336, 62_519], RedmineDashboards.split_ids('62519-33333', limit: 5)
  # end
end
