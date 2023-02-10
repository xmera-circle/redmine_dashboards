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

class MySpentTimeBlockValidationTest < RedmineDashboards::TestCase
  def setup
    @my_spent_time_block = MySpentTimeBlock.instance
    @my_spent_time_block.days = '5'
    @my_spent_time_block.table = '0'
  end

  def teardown
    @my_spent_time_block = nil
  end

  def test_valid_my_spent_time
    assert @my_spent_time_block.valid?
  end

  def test_invalid_days
    @my_spent_time_block.days = '101'
    assert @my_spent_time_block.invalid?
  end

  def test_invalid_table
    @my_spent_time_block.table = 'invalid'
    assert @my_spent_time_block.invalid?
  end
end
