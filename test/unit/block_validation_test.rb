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
  def test_valid_activity_settings
    activity_block = find_or_create_block(ActivityBlock)
    settings = { max_entries: '5', me_only: '1' }
    activity_block.send :update_settings, settings
    assert activity_block.valid?, activity_block.errors.full_messages
  end

  def test_invalid_activity_settings
    activity_block = find_or_create_block(ActivityBlock)
    settings = { max_entries: nil, me_only: 'yes' }
    activity_block.send :update_settings, settings
    assert activity_block.invalid?, activity_block.errors.full_messages
  end

  def test_valid_documents_settings
    documents_block = find_or_create_block(DocumentsBlock)
    settings = { max_entries: '5' }
    documents_block.send :update_settings, settings
    assert documents_block.valid?, documents_block.errors.full_messages
  end

  def test_invalid_documents_settings
    documents_block = find_or_create_block(DocumentsBlock)
    settings = { max_entries: '0' }
    documents_block.send :update_settings, settings
    assert documents_block.invalid?, documents_block.errors.full_messages
  end

  def test_valid_feed_settings
    feed_block = find_or_create_block(FeedBlock)
    settings = { max_entries: '5', url: 'https://www.ruby-lang.org/de/feeds/news.rss' }
    feed_block.send :update_settings, settings
    assert feed_block.valid?, feed_block.errors.full_messages
  end

  def test_invalid_feed_settings
    feed_block = find_or_create_block(FeedBlock)
    settings = { max_entries: '0', url: 'https://www.ruby-lang.org/de/feeds/news.rss' }
    feed_block.send :update_settings, settings
    assert feed_block.invalid?, feed_block.errors.full_messages
  end

  def test_valid_issue_query_settings
    issue_query_block = find_or_create_block(IssueQueryBlock)
    settings = { max_entries: '5' }
    issue_query_block.send :update_settings, settings
    assert issue_query_block.valid?, issue_query_block.errors.full_messages
  end

  def test_invalid_issue_query_settings
    issue_query_block = find_or_create_block(IssueQueryBlock)
    settings = { max_entries: '0' }
    issue_query_block.send :update_settings, settings
    assert issue_query_block.invalid?, issue_query_block.errors.full_messages
  end

  def test_valid_my_spent_time_settings
    my_spent_time_block = find_or_create_block(MySpentTimeBlock)
    settings = { days: '5', table: '1' }
    my_spent_time_block.send :update_settings, settings
    assert my_spent_time_block.valid?, my_spent_time_block.errors.full_messages
  end

  def test_invalid_my_spent_time_settings
    my_spent_time_block = find_or_create_block(MySpentTimeBlock)
    settings = { days: '0', table: '100' }
    my_spent_time_block.send :update_settings, settings
    assert my_spent_time_block.invalid?, my_spent_time_block.errors.full_messages
  end

  def test_valid_news_settings
    news_block = find_or_create_block(NewsBlock)
    settings = { max_entries: '5' }
    news_block.send :update_settings, settings
    assert news_block.valid?, news_block.errors.full_messages
  end

  def test_invalid_news_settings
    news_block = find_or_create_block(NewsBlock)
    settings = { max_entries: '0' }
    news_block.send :update_settings, settings
    assert news_block.invalid?, news_block.errors.full_messages
  end

  def test_valid_text_settings
    text_block = find_or_create_block(TextAsyncBlock)
    settings = { text: 'Lore ipsum', css: 'unset' }
    text_block.send :update_settings, settings
    assert text_block.valid?, text_block.errors.full_messages
  end

  def test_invalid_text_settings
    text_block = find_or_create_block(TextAsyncBlock)
    settings = { text: '' }
    text_block.send :update_settings, settings
    assert text_block.invalid?, text_block.errors.full_messages
  end

  def test_valid_text_async_settings
    text_block = find_or_create_block(TextBlock)
    settings = { text: 'Lore ipsum', css: 'unset' }
    text_block.send :update_settings, settings
    assert text_block.valid?, text_block.errors.full_messages
  end

  def test_invalid_text_async_settings
    text_block = find_or_create_block(TextBlock)
    settings = { text: '' }
    text_block.send :update_settings, settings
    assert text_block.invalid?, text_block.errors.full_messages
  end
end
