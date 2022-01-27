# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2016 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/RedmineDashboards>.
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
    module WelcomeControllerPatch
      def self.included(base)
        base.include(InstanceMethods)
        base.class_eval do
          before_action :find_dashboard, only: %i[index]

          helper :issues
          helper :queries
          helper :dashboards_queries
          helper :dashboards_settings
          helper :dashboards
          helper :dashboards_routes

          include DashboardsHelper
        end
      end

      module InstanceMethods
        private

        def find_dashboard
          if params[:dashboard_id].present?
            begin
              @dashboard = Dashboard.welcome_only.find params[:dashboard_id]
              raise ::Unauthorized unless @dashboard.visible?
            rescue ActiveRecord::RecordNotFound
              return render_404
            end
          else
            @dashboard = Dashboard.default DashboardContentWelcome::TYPE_NAME
          end

          resently_used_dashboard_save @dashboard
          @can_edit = @dashboard&.editable?
          @dashboard_sidebar = dashboard_sidebar? @dashboard, params
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless WelcomeController.included_modules.include?(RedmineDashboards::Extensions::WelcomeControllerPatch)
    WelcomeController.include(RedmineDashboards::Extensions::WelcomeControllerPatch)
  end
end
