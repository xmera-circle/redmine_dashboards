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

class LegacyLeftBlock < DashboardBlock
  def register_type
    'legacy_left'
  end

  def register_label
    -> { l(:label_dashboard_legacy_left) }
  end

  def register_specs
    { no_settings: true }
  end

  def register_settings
    {}
  end

  ##
  # The legacy left block will only be provided in the block selection
  # list if there is a hook listener providing a partial with content.
  #
  def forbidden?(user, project)
    return super if Redmine::Hook.hook_listeners(hook).present?

    true
  end

  private

  def hook
    :view_welcome_index_left
  end
end
