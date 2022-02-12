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

class ChartBlock < DashboardBlock
  attr_accessor :title, :project_id, :filter, :chart_type, :legend

  validates :title, length: { maximum: 120 }
  validates :project_id, presence: true
  validates :filter, inclusion: { in: :filter_list }, allow_nil: true
  validates :chart_type, inclusion: { in: :chart_type_list }, allow_nil: true
  validates :legend, inclusion: { in: %w[0 1] }, allow_nil: true

  def register_type
    'chart'
  end

  def register_label
    -> { l(:label_chart) }
  end

  def register_specs
    { permission: :view_issues,
      partial: 'dashboards/blocks/chart',
      max_frequency: MAX_MULTIPLE_OCCURS,
      filter_list: %w[rows statuses],
      chart_type_list: %w[bar horizontalBar],
      chartjs: true }
  end

  def register_settings
    { title: nil,
      project_id: nil,
      filter: nil,
      chart_type: nil,
      legend: nil }
  end

  private

  def filter_list
    specs[:filter_list]
  end

  def chart_type_list
    specs[:chart_type_list]
  end
end
