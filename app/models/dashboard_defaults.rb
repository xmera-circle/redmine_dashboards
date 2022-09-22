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

class DashboardDefaults
  class << self
    def create_welcome_dashboard
      # Store the current user
      current_user = User.current
      # Change to admin user temporarily
      admin = User.admin.active.first
      return unless admin

      User.current = User.find_by(id: admin.id)

      return if Dashboard.exists? dashboard_type: DashboardContentWelcome::TYPE_NAME

      Rails.logger.debug 'Creating welcome default dashboard'
      dashboard = Dashboard.create! name: 'Welcome dashboard',
                                    dashboard_type: DashboardContentWelcome::TYPE_NAME,
                                    system_default: true,
                                    user_id: User.current.id,
                                    visibility: 2
      # Change back to the inital current user
      User.current = current_user
      dashboard
    end
  end
end
