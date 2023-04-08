# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
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

require File.expand_path '../../test_helper', __dir__

class ActivityBlockValidationTest < RedmineDashboards::TestCase
  def setup
    @activity_block = ActivityBlock.instance
    @activity_block.max_entries = '5'
    @activity_block.me_only = '1'
  end

  def teardown
    @activity_block = nil
  end

  def test_valid_activities
    assert @activity_block.valid?
  end

  def test_invalid_activity_number_of_entries
    @activity_block.max_entries = '101'
    assert @activity_block.invalid?
  end

  def test_invalid_me_only
    @activity_block.me_only = nil
    assert @activity_block.invalid?
  end
end
