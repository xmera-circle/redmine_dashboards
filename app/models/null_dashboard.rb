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

##
# Prevents especially default Redmine tests from failing.
#
class NullDashboard
  attr_reader :content, :errors
  attr_writer :name

  def initialize
    @content = DashboardContentNull.new
    @errors = ActiveModel::Errors.new(self)
  end

  def id
    nil
  end

  def name
    'unset'
  end

  def dashboard_type
    ''
  end

  def editable?
    false
  end

  def enable_sidebar?
    false
  end

  def always_expose?
    false
  end

  def system_default?
    false
  end

  def destroyable?
    false
  end

  def available_groups
    []
  end

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, _options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end
end
