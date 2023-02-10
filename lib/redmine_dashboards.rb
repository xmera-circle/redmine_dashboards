# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2021-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

require_relative 'redmine_dashboards/extensions/user_patch'
require_relative 'redmine_dashboards/extensions/user_preference_patch'
require_relative 'redmine_dashboards/extensions/welcome_controller_patch'
require_relative 'redmine_dashboards/wiki_macros/button_macro'

require_relative 'redmine_dashboards/hooks/base_view_listener'

module RedmineDashboards
  SEPARATOR = ' » '
  class << self
    def setup
      register_presenters
      top_menu_settings
      AdvancedPluginHelper::Patch.apply do
        { klass: RedmineDashboards,
          method: :prepare_dashboards }
      end
      %w[user_patch user_preference_patch welcome_controller_patch].each do |patch|
        AdvancedPluginHelper::Patch.register(send(patch))
      end
    end

    def user_patch
      { klass: User, patch: RedmineDashboards::Extensions::UserPatch, strategy: :include }
    end

    def user_preference_patch
      { klass: UserPreference, patch: RedmineDashboards::Extensions::UserPreferencePatch, strategy: :include }
    end

    def welcome_controller_patch
      { klass: WelcomeController, patch: RedmineDashboards::Extensions::WelcomeControllerPatch, strategy: :include }
    end

    def prepare_dashboards
      RedmineDashboards.render_async_configuration
      RedmineDashboards.add_helpers
      RedmineDashboards.instanciate_blocks
    end

    def register_presenters
      AdvancedPluginHelper::Presenter.register RedmineDashboards::DashboardPresenter, Dashboard
      AdvancedPluginHelper::Presenter.register RedmineDashboards::IssueQueryPresenter, IssueQuery
      AdvancedPluginHelper::Presenter.register RedmineDashboards::NewsPresenter, News
    end

    def top_menu_settings
      return if Rails.env.test?

      delete_my_page
      Redmine::MenuManager.map(:top_menu) do |menu|
        menu.push :my_page, { controller: 'my', action: 'page' },
                  after: :home, if: proc { User.current.logged? && show_my_page? }
      end
    end

    def delete_my_page
      Redmine::MenuManager.map(:top_menu).delete(:my_page)
    end

    def show_my_page?
      Setting.plugin_redmine_dashboards[:show_my_page].presence
    end

    def partial
      'settings/redmine_dashboards'
    end

    def defaults
      { show_my_page: '0' }
    end

    def render_async_configuration
      RenderAsync.configuration.jquery = true
    end

    def add_helpers
      ActiveSupport.on_load(:action_view) { include RedmineDashboards::Helpers }
    end

    def instanciate_blocks
      ActivityBlock.instance
      DocumentsBlock.instance
      FeedBlock.instance
      IssueQueryBlock.instance
      LegacyLeftBlock.instance
      LegacyRightBlock.instance
      MySpentTimeBlock.instance
      NewsBlock.instance
      TextAsyncBlock.instance
      TextBlock.instance
      WelcomeBlock.instance
      ButtonBlock.instance
      ChartBlock.instance
      IssueCounterBlock.instance
      CalendarBlock.instance
      return unless Redmine::Plugin.installed?(:redmine_dashboards)

      OpenApprovalsBlock.instance
      LockedDocumentsBlock.instance
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

    def load_settings(plugin_id = 'redmine_dashboards')
      cached_settings_name = "@load_settings_#{plugin_id}"
      cached_settings = instance_variable_get cached_settings_name
      if cached_settings.nil?
        data = YAML.safe_load(ERB.new(File.read(File.join(plugin_dir(plugin_id), '/config/settings.yml'))).result) || {}
        instance_variable_set cached_settings_name, data.symbolize_keys
      else
        cached_settings
      end
    end

    def plugin_dir(plugin_id = 'redmine_dashboards')
      if Gem.loaded_specs[plugin_id].nil?
        File.join Redmine::Plugin.directory, plugin_id
      else
        Gem.loaded_specs[plugin_id].full_gem_path
      end
    end
  end
end
