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

class IssueCounterBlockValidationTest < RedmineDashboards::TestCase
  def setup
    @issue_counter_block = IssueCounterBlock.instance
    @issue_counter_block.title = 'Issue Counter'
    @issue_counter_block.css = 'left'
    @issue_counter_block.color = '#83BF40'
  end

  def teardown
    @issue_counter_block = nil
  end

  def test_valid_issue_counter
    assert @issue_counter_block.valid?
  end

  def test_valid_issue_counter_title_when_not_given
    @issue_counter_block.title = nil
    assert @issue_counter_block.valid?
  end

  def test_invalid_css
    @issue_counter_block.css = 'invalid'
    assert @issue_counter_block.invalid?
  end

  def test_invalid_issue_counter_color
    @issue_counter_block.color = '83BF40'
    assert @issue_counter_block.invalid?
  end
end
