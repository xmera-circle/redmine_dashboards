# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2016 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/RedmineDashboards>.
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

class DashboardContentWelcome < DashboardContent
  TYPE_NAME = 'WelcomeDashboard'

  def block_definitions
    blocks = super

    # legacy_left or legacy_right should not be moved to DashboardContent,
    # because DashboardContent is used for areas in other plugins
    blocks['legacy_left'] = { label: l(:label_dashboard_legacy_left),
                              no_settings: true }

    blocks['legacy_right'] = { label: l(:label_dashboard_legacy_right),
                               no_settings: true }

    blocks['welcome'] = { label: l(:setting_welcome_text),
                          no_settings: true,
                          partial: 'dashboards/blocks/welcome' }

    blocks['activity'] = { label: l(:label_activity),
                           async: { data_method: 'activity_dashboard_data',
                                    partial: 'dashboards/blocks/activity' } }

    blocks
  end

  # Returns the default layout for a new dashboard
  def default_layout
    {
      'left' => %w[welcome legacy_left],
      'right' => ['legacy_right']
    }
  end
end
