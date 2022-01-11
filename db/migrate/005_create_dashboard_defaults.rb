# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2020 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/additionals>.
#
# Copyright (C) 2021 Liane Hampe <liaham@xmera.de>, xmera.
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

class CreateDashboardDefaults < ActiveRecord::Migration[5.2]
  def up
    User.current = User.find_by(id: ENV['DEFAULT_USER_ID'].presence || User.admin.active.first.id)

    return if Dashboard.exists? dashboard_type: DashboardContentWelcome::TYPE_NAME

    Rails.logger.debug 'Creating welcome default dashboard'
    Dashboard.create! name: 'Welcome dashboard',
                      dashboard_type: DashboardContentWelcome::TYPE_NAME,
                      system_default: true,
                      author_id: User.current.id,
                      visibility: 2
  end
end
