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

require File.expand_path '../test_helper', __dir__

class TestTextBlock < DashboardBlock
  def register_name
    'test_text'
  end

  def register_label
    -> { 'Test Text Block' }
  end

  def register_specs
    {}
  end

  def register_settings
    {}
  end
end

class TestNewsBlock < DashboardBlock
  def register_name
    'test_news'
  end

  def register_label
    -> { 'Test News Block' }
  end

  def register_specs
    {}
  end

  def register_settings
    {}
  end
end

class DashboardBlockTest < RedmineDashboards::TestCase
  def setup
    @text_block = TestTextBlock.instance
    @news_block = TestNewsBlock.instance
  end

  def test_all
    actual = DashboardBlock.all
    block_classes.map do |block_class|
      assert actual.include? block_class
    end
  end

  def test_singleton
    assert_raises TypeError, "can't clone instance of singleton TextBlock" do
      @text_block.clone
    end
  end

  def test_name
    expected = 'test_text'
    actual = @text_block.name
    assert_equal expected, actual
  end

  def test_not_implemented
    assert_raises DashboardBlock::NotImplementedError do
      @text_block.validate
    end
  end

  private

  def block_classes
    names.map { |name| Object.const_get name }
  end

  def names
    %w[TestTextBlock TestNewsBlock]
  end
end
