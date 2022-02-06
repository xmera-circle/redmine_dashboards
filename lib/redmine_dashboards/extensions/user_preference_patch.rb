# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2016 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/additionals>.
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

module RedmineDashboards
  module Extensions
    module UserPreferencePatch
      def self.included(base)
        base.include(InstanceMethods)
        base.class_eval do
          safe_attributes 'autowatch_involved_issue', 'recently_used_dashboards'
        end
      end

      module InstanceMethods
        def recently_used_dashboards
          self[:recently_used_dashboards]
        end

        def recently_used_dashboard(dashboard_type, _project = nil)
          r = self[:recently_used_dashboards] ||= {}
          r = {} unless r.is_a? Hash

          return unless r.is_a?(Hash) && r.key?(dashboard_type)

          r[dashboard_type]
        end

        def recently_used_dashboards=(value)
          self[:recently_used_dashboards] = value
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless UserPreference.included_modules.include?(RedmineDashboards::Extensions::UserPreferencePatch)
    UserPreference.include(RedmineDashboards::Extensions::UserPreferencePatch)
  end
end
