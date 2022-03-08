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
  def register_type
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
  attr_accessor :title, :max_entries

  validates :title, presence: true

  def register_type
    'test_news'
  end

  def register_label
    'Test News Block'
  end

  def register_specs
    {}
  end

  def register_settings
    { title: nil,
      max_entries: nil }
  end
end

class DashboardBlockTest < RedmineDashboards::TestCase
  fixtures :dashboards, :users

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

  def test_type
    expected = 'test_text'
    actual = @text_block.type
    assert_equal expected, actual
  end

  def test_find_block
    actual = DashboardBlock.find_block('test_text')
    expected = @text_block
    assert_equal expected, actual
  end

  def test_registered
    assert DashboardBlock.registered?(TestNewsBlock)
  end

  def test_label
    actual = [@text_block.label, @news_block.label]
    expected = ['Test Text Block', 'Test News Block']
    assert_equal expected, actual
  end

  def test_update_and_clear_settings
    settings = { title: 'Latest News', max_entries: '2' }
    @news_block.send :update_settings, settings
    actual = [@news_block.title, @news_block.max_entries]
    expected = ['Latest News', '2']
    assert_equal expected, actual
    @news_block.send :clear_settings
    actual = [@news_block.title, @news_block.max_entries]
    assert actual.compact.empty?
  end

  def test_valid_settings
    dashboard = dashboards :system_default_welcome
    settings = { title: 'Latest News', max_entries: '2' }
    @news_block.validate_settings(settings, dashboard)
    assert dashboard.valid?
  end

  def test_invalid_settings
    dashboard = dashboards :system_default_welcome
    settings = { title: nil, max_entries: '2' }
    dashboard = @news_block.validate_settings(settings, dashboard)
    assert dashboard.errors.any?
  end

  private

  def block_classes
    names.map { |name| Object.const_get name }
  end

  def names
    %w[TestTextBlock TestNewsBlock]
  end
end
