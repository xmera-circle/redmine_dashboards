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

class IssueQueryBlock < DashboardBlock
  attr_accessor :max_entries, :query_id, :columns
  validates :max_entries, presence: true, numericality: true, inclusion: { in: (1..100).map(&:to_s) }

  def register_type
    'issue_query'
  end

  def register_label
    -> { l(:label_query_with_name, l(:label_issue_plural)) }
  end

  def register_specs
    { permission: :view_issues,
      query_block: { label: -> { l(:label_issue_plural) },
                     list_partial: 'issues/list',
                     class: IssueQuery,
                     link_helper: '_project_issues_path',
                     count_method: 'issue_count',
                     entries_method: 'issues',
                     entities_var: :issues,
                     with_project: true },
      max_frequency: MAX_MULTIPLE_OCCURS }
  end

  def register_settings
    { max_entries: nil }
  end
end
