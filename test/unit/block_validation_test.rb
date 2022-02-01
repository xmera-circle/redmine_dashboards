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

class BlockValidationTest < RedmineDashboards::TestCase
  def setup
    @activity_block = ActivityBlock.instance
    @documents_block = DocumentsBlock.instance
    @feed_block = FeedBlock.instance
    @issue_query_block = IssueQueryBlock.instance
    @my_spent_time_block = MySpentTimeBlock.instance
    @news_block = NewsBlock.instance
    @text_async_block = TextAsyncBlock.instance
    @text_block = TextBlock.instance
  end

  def test_valid_activity_settings
    settings = { max_entries: '5', me_only: '1' }
    @activity_block.send :update_settings, settings
    assert @activity_block.valid?
  end

  def test_invalid_activity_settings
    settings = { max_entries: nil, me_only: '1' }
    @activity_block.send :update_settings, settings
    assert @activity_block.invalid?
  end

  def test_valid_documents_settings
    settings = { max_entries: '5' }
    @documents_block.send :update_settings, settings
    assert @documents_block.valid?
  end

  def test_invalid_documents_settings
    settings = { max_entries: '0' }
    @documents_block.send :update_settings, settings
    assert @documents_block.invalid?
  end

  def test_valid_feed_settings
    settings = { max_entries: '5', url: 'https://www.ruby-lang.org/de/feeds/news.rss' }
    @feed_block.send :update_settings, settings
    assert @feed_block.valid?
  end

  def test_invalid_feed_settings
    settings = { max_entries: '0', url: 'https://www.ruby-lang.org/de/feeds/news.rss' }
    @feed_block.send :update_settings, settings
    assert @feed_block.invalid?
  end

  def test_valid_issue_query_settings
    settings = { max_entries: '5' }
    @issue_query_block.send :update_settings, settings
    assert @issue_query_block.valid?
  end

  def test_invalid_issue_query_settings
    settings = { max_entries: '0' }
    @issue_query_block.send :update_settings, settings
    assert @issue_query_block.invalid?
  end

  def test_valid_my_spent_time_settings
    settings = { days: '5' }
    @my_spent_time_block.send :update_settings, settings
    assert @my_spent_time_block.valid?
  end

  def test_invalid_my_spent_time_settings
    settings = { days: '0' }
    @my_spent_time_block.send :update_settings, settings
    assert @my_spent_time_block.invalid?
  end

  def test_valid_news_settings
    settings = { max_entries: '5' }
    @news_block.send :update_settings, settings
    assert @news_block.valid?
  end

  def test_invalid_news_settings
    settings = { max_entries: '0' }
    @news_block.send :update_settings, settings
    assert @news_block.invalid?
  end

  def test_valid_text_settings
    settings = { text: 'Lore ipsum' }
    @text_block.send :update_settings, settings
    assert @text_block.valid?
  end

  def test_invalid_text_settings
    settings = { text: '' }
    @text_block.send :update_settings, settings
    assert @text_block.invalid?
  end

  def test_valid_text_async_settings
    settings = { text: 'Lore ipsum' }
    @text_block.send :update_settings, settings
    assert @text_block.valid?
  end

  def test_invalid_text_async_settings
    settings = { text: '' }
    @text_block.send :update_settings, settings
    assert @text_block.invalid?
  end
end
