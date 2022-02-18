# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
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

require File.expand_path '../../test_helper', __dir__

class ChartBlockValidationTest < RedmineDashboards::TestCase
  def setup
    @chart_block = ChartBlock.instance
    @chart_block.title = 't' * 120
    @chart_block.project_id = '1'
    @chart_block.filter = 'rows'
    @chart_block.chart_type = 'bar'
    @chart_block.legend = '0'
  end

  def teardown
    @chart_block = nil
  end

  def test_valid_chart
    assert @chart_block.valid?
  end

  def test_invalid_chart_title
    @chart_block.title = 't' * 121
    assert @chart_block.invalid?
  end

  def test_invalid_project_id
    @chart_block.project_id = nil
    assert @chart_block.invalid?
  end

  def test_invalid_filter
    @chart_block.filter = 'invalid'
    assert @chart_block.invalid?
  end

  def test_invalid_chart_type
    @chart_block.chart_type = 'invalid'
    assert @chart_block.invalid?
  end

  def test_invalid_legend
    @chart_block.legend = 'invalid'
    assert @chart_block.invalid?
  end
end
