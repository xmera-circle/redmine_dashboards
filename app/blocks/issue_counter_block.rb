# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2022 Liane Hampe <liaham@xmera.de>, xmera.
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

class IssueCounterBlock < IssueQueryBlock
  attr_accessor :title, :color, :css

  validates :css, inclusion: { in: BlockStyles.position_classes }, allow_nil: true
  validates :color, format: { with: /\A#([a-f0-9]{3}){,2}\z/i }

  def register_type
    'issue_counter'
  end

  def register_label
    -> { l(:label_issue_counter_with_name, l(:label_issue_plural)) }
  end

  def register_specs
    { permission: :view_issues,
      query_block: { label: -> { l(:label_issue_plural) },
                     class: IssueQuery,
                     link_helper: '_project_issues_path',
                     count_method: 'issue_count',
                     with_project: true },
      async: { required_settings: %i[query_id],
               exposed_params: %i[sort],
               partial: 'dashboards/blocks/issue_counter' },
      max_frequency: MAX_MULTIPLE_OCCURS }
  end

  def register_settings
    { query_id: nil,
      user_id: nil,
      user_is_admin: nil,
      title: nil,
      color: nil,
      css: nil }
  end
end
