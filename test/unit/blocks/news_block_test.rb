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

class NewsBlockValidationTest < RedmineDashboards::TestCase
  def setup
    @news_block = NewsBlock.instance
    @news_block.max_entries = '5'
  end

  def teardown
    @news_block = nil
  end

  def test_valid_news
    assert @news_block.valid?
  end

  def test_invalid_max_entries
    @news_block.max_entries = '101'
    assert @news_block.invalid?
  end
end
