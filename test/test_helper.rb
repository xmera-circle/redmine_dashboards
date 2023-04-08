# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2016 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/additionals>.
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

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start :rails do
    add_filter 'init.rb'
    root File.expand_path "#{File.dirname __FILE__}/.."
  end
end

require File.expand_path "#{File.dirname __FILE__}/../../../test/test_helper"
require File.expand_path "#{File.dirname __FILE__}/global_test_helper"
require File.expand_path "#{File.dirname __FILE__}/crud_controller_base"

module RedmineDashboards
  module TestHelper
    include RedmineDashboards::GlobalTestHelper

    def prepare_tests
      Role.where(id: [1, 2]).each do |role|
        role.permissions << :manage_own_dashboards
        role.save
      end

      Role.where(id: [1]).each do |role|
        role.permissions << :manage_system_dashboards
        role.save
      end

      Project.where(id: [1, 2]).each do |project|
        EnabledModule.create project: project, name: 'issue_tracking'
      end
    end
  end

  module PluginFixturesLoader
    def fixtures(*table_names)
      dir = "#{File.dirname __FILE__}/fixtures/"
      table_names.each do |table|
        ActiveRecord::FixtureSet.create_fixtures dir, table if File.exist? "#{dir}/#{table}.yml"
      end
      super table_names
    end
  end

  class ControllerTest < Redmine::ControllerTest
    include RedmineDashboards::TestHelper
    extend PluginFixturesLoader
  end

  class TestCase < ActiveSupport::TestCase
    include RedmineDashboards::TestHelper
    extend PluginFixturesLoader
  end

  class IntegrationTest < Redmine::IntegrationTest
    extend PluginFixturesLoader
  end
end
