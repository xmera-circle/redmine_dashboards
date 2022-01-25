# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2020 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/additionals>.
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

class DashboardContent
  include Redmine::I18n

  attr_accessor :user, :project

  MAX_MULTIPLE_OCCURS = 8
  DEFAULT_MAX_ENTRIES = 10
  RENDER_ASYNC_CACHE_EXPIRES_IN = 30

  class << self
    def types
      descendants.map { |dc| dc::TYPE_NAME }
    end
  end

  def with_chartjs?
    false
  end

  def initialize(attr = {})
    self.user = attr[:user].presence || User.current
    self.project = attr[:project].presence
  end

  def groups
    %w[top left right bottom]
  end

  def block_definitions
    {
      'issuequery' => { label: l(:label_query_with_name, l(:label_issue_plural)),
                        permission: :view_issues,
                        query_block: {
                          label: l(:label_issue_plural),
                          list_partial: 'issues/list',
                          class: IssueQuery,
                          link_helper: '_project_issues_path',
                          count_method: 'issue_count',
                          entries_method: 'issues',
                          entities_var: :issues,
                          with_project: true
                        },
                        max_occurs: DashboardContent::MAX_MULTIPLE_OCCURS },
      'text' => { label: l(:label_text_sync),
                  max_occurs: MAX_MULTIPLE_OCCURS,
                  partial: 'dashboards/blocks/text' },
      'text_async' => { label: l(:label_text_async),
                        max_occurs: MAX_MULTIPLE_OCCURS,
                        async: { required_settings: %i[text],
                                 partial: 'dashboards/blocks/text_async' } },
      'news' => { label: l(:label_news_latest),
                  permission: :view_news },
      'documents' => { label: l(:label_document_plural),
                       permission: :view_documents },
      'my_spent_time' => { label: l(:label_my_spent_time),
                           permission: :log_time },
      'feed' => { label: l(:label_dashboard_feed),
                  max_occurs: DashboardContent::MAX_MULTIPLE_OCCURS,
                  async: { required_settings: %i[url],
                           cache_expires_in: 600,
                           skip_user_id: true,
                           partial: 'dashboards/blocks/feed' } }
    }
  end

  # Returns the available blocks
  def available_blocks
    return @available_blocks if defined? @available_blocks

    available_blocks = block_definitions.reject do |_block_name, block_specs|
      (block_specs.key?(:permission) && !user.allowed_to?(block_specs[:permission], project, global: true)) ||
        (block_specs.key?(:admin_only) && block_specs[:admin_only] && !user.admin?) ||
        (block_specs.key?(:if) && !block_specs[:if].call(project))
    end

    @available_blocks = available_blocks.sort_by { |_k, v| v[:label] }.to_h
  end

  def block_options(blocks_in_use = [])
    options = []
    available_blocks.each do |block, block_options|
      indexes = block_indexes(blocks_in_use, block)
      indexes.compact!

      occurs = indexes.size
      block_id = indexes.any? ? "#{block}__#{indexes.max + 1}" : block
      disabled = (occurs >= (available_blocks[block][:max_occurs] || 1))
      block_id = nil if disabled

      options << [block_options[:label], block_id]
    end
    options
  end

  def block_indexes(blocks_in_use, block)
    blocks_in_use.map do |item|
      Regexp.last_match(2).to_i if item =~ /\A#{block}(__(\d+))?\z/
    end
  end

  def valid_block?(block, blocks_in_use = [])
    block.present? && block_options(blocks_in_use).map(&:last).include?(block)
  end

  def find_block(block)
    block.to_s =~  /\A(.*?)(__\d+)?\z/
    name = Regexp.last_match 1
    available_blocks.key?(name) ? available_blocks[name].merge(name: name) : nil
  end

  # Returns the default layout for a new dashboard
  def default_layout
    {
      'left' => ['legacy_left'],
      'right' => ['legacy_right']
    }
  end
end
