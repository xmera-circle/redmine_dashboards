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

require 'redmine_dashboards/extensions/user_preference_patch'
require 'redmine_dashboards/extensions/welcome_controller_patch'

require 'redmine_dashboards/hooks/base_view_listener'

module RedmineDashboards
  LIST_SEPARATOR = ' » '
  class << self
    def setup
      RenderAsync.configuration.jquery = true
      # Global helpers
      ActionView::Base.include RedmineDashboards::Helpers
    end

    def true?(value)
      return false if value.is_a? FalseClass
      return true if value.is_a?(TrueClass) || value.to_i == 1 || value.to_s.casecmp('true').zero?

      false
    end

    # @return falseClass value is nil or false
    def false?(value)
      !true?(value)
    end
  end
end
