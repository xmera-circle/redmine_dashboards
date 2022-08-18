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

class MySpentTimeBlock < DashboardBlock
  attr_accessor :days

  validates :days, presence: true, numericality: true, inclusion: { in: (1..100).map(&:to_s) }, allow_nil: true

  def register_type
    'my_spent_time'
  end

  def register_label
    -> { l(:label_my_spent_time) }
  end

  def register_specs
    { permission: :log_time,
      partial: 'dashboards/blocks/my_spent_time' }
  end

  def register_settings
    { days: nil }
  end

  def prepare_custom_locals(settings, dashboard)
    days = calculate_days(settings)
    entries_today, entries_days = quey_time_entries(dashboard, days)
    { entries_today: entries_today,
      entries_days: entries_days,
      days: days }
  end

  private

  def calculate_days(settings)
    days = settings[:days].to_i
    7 if days < 1 || days > 365
  end

  def quey_time_entries(dashboard, days)
    scope = TimeEntry.where user_id: User.current.id
    scope = scope.where project_id: dashboard.content_project.id unless dashboard.content_project.nil?
    entries_today = query_entries_today(scope)
    entries_days = query_entries_days(scope, days)
    [entries_today, entries_days]
  end

  def query_entries_today(base)
    base.where spent_on: User.current.today
  end

  def query_entries_days(base, days)
    base.where spent_on: User.current.today - (days - 1)..User.current.today
  end
end
