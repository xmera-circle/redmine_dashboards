# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2022-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

class CalendarBlock < DashboardBlock
  attr_accessor :user_id, :user_is_admin

  def register_type
    'calendar'
  end

  def register_label
    -> { l(:label_calendar) }
  end

  def register_specs
    { no_settings: true,
      async: { partial: 'dashboards/blocks/calendar' } }
  end

  def register_settings
    { user_id: nil,
      user_is_admin: nil }
  end

  ##
  # A calendar object containing all issues in the current week for the current
  # user.
  #
  def calendar
    calendar = Redmine::Helpers::Calendar.new(User.current.today, current_language, :week)
    calendar.events = issues(calendar)
    calendar
  end

  private

  ##
  # @params calendar [Redmine::Helpers::Calendar] A calendar helper object for
  #   computing start and end dates.
  # @return [Array(Issue)] An array of issues within the required time interval.
  #
  def issues(calendar)
    Issue
      .visible
      .where(project: User.current.projects)
      .where('(start_date>=? and start_date<=?) or (due_date>=? and due_date<=?)', calendar.startdt, calendar.enddt, calendar.startdt, calendar.enddt)
      .includes(:project, :tracker, :priority, :assigned_to)
      .references(:project, :tracker, :priority, :assigned_to)
      .to_a
  end
end
