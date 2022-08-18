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

class ActivityBlock < DashboardBlock
  attr_accessor :max_entries, :me_only, :user_id, :user_is_admin

  validates :max_entries, presence: true, numericality: true, inclusion: { in: (1..100).map(&:to_s) }, allow_nil: true
  validates :me_only, inclusion: { in: %w[0 1] }

  def register_type
    'activity'
  end

  def register_label
    -> { l(:label_activity) }
  end

  def register_specs
    { async: { partial: 'dashboards/blocks/activity' } }
  end

  def register_settings
    { max_entries: nil,
      me_only: nil,
      user_id: nil,
      user_is_admin: nil }
  end

  def activity(settings, dashboard)
    self.max_entries = settings.fetch(:max_entries, default_max_entries).to_i
    user = User.current
    options = {}
    options[:user] = user if RedmineDashboards.true? settings[:me_only]
    options[:project] = dashboard.content_project if dashboard.content_project.present?
    query_events(user, options)
  end

  private

  def query_events(user, options)
    Redmine::Activity::Fetcher.new(user, options)
                              .events(nil, nil, limit: max_entries)
                              .group_by { |event| user.time_to_date event.event_datetime }
  end
end
