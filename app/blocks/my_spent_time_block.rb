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
  attr_accessor :days, :table

  validates :days, presence: true, numericality: true, inclusion: { in: (1..100).map(&:to_s) }, allow_nil: true
  validates :table, inclusion: { in: %w[0 1] }, allow_nil: true

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
    { days: nil,
      table: nil }
  end

  def prepare_custom_locals(settings, dashboard)
    self.days = calculate_days(settings)
    self.table = RedmineDashboards.true?(settings[:table])
    return locals_for_simple_time_entries(dashboard, days) unless table

    locals_for_time_entries_with_issues(dashboard, days)
  end

  private

  def locals_for_simple_time_entries(dashboard, days)
    entries_today, entries_days = query_time_entries(dashboard, days)
    { entries_today: entries_today,
      entries_days: entries_days,
      days: days }
  end

  def locals_for_time_entries_with_issues(_dashboard, days)
    entries = query_time_entries_with_issues(days)
    { entries: entries,
      entries_by_day: query_time_entries_with_issues_by_day(entries),
      days: days }
  end

  def calculate_days(settings)
    days = settings[:days].to_i
    week = 7 if days < 1 || days > 365
    week || days
  end

  def query_time_entries(dashboard, days)
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

  def query_time_entries_with_issues(days)
    TimeEntry
      .where("#{TimeEntry.table_name}.user_id = ? AND #{TimeEntry.table_name}.spent_on BETWEEN ? AND ?", User.current.id, User.current.today - (days - 1), User.current.today)
      .joins(:activity, :project)
      .references(issue: %i[tracker status])
      .includes(issue: %i[tracker status])
      .order("#{TimeEntry.table_name}.spent_on DESC, #{Project.table_name}.name ASC, #{Tracker.table_name}.position ASC, #{Issue.table_name}.id ASC")
      .to_a
  end

  def query_time_entries_with_issues_by_day(entries)
    entries.group_by(&:spent_on)
  end
end
