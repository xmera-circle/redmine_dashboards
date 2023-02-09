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

require File.expand_path('lib/redmine_dashboards', __dir__)

Redmine::Plugin.register :redmine_dashboards do
  name 'Redmine Dashboards'
  author 'Liane Hampe, Alexander Meindl'
  description 'Flexible dashboards for Redmine welcome page'
  version '1.1.1'
  url 'https://circle.xmera.de/projects/redmine-dashboards'
  author_url 'https://github.com/liaham'

  requires_redmine version_or_higher: '4.2.0'
  requires_redmine_plugin :advanced_plugin_helper, version_or_higher: '0.2.0'

  settings partial: RedmineDashboards.partial,
           default: RedmineDashboards.defaults

  full_action_set = %i[index new create edit update destroy]
  content_action_set = %i[update_layout_setting
                          add_block
                          remove_block
                          order_blocks]

  permission :manage_system_dashboards,
             { dashboards: full_action_set | content_action_set },
             require: :loggedin,
             read: true
  # Public means here not private, i.e., role dashboards and public dashboards
  permission :manage_public_dashboards,
             { dashboards: full_action_set | content_action_set },
             require: :loggedin,
             read: true
  permission :manage_own_dashboards,
             { dashboards: full_action_set | content_action_set },
             require: :loggedin
  permission :manage_dashboards,
             { dashboards: full_action_set | content_action_set },
             require: :loggedin,
             read: true
end

RedmineDashboards.setup
