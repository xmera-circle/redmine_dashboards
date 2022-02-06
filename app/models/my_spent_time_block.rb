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

class MySpentTimeBlock < DashboardBlock
  attr_accessor :days
  validates :days, presence: true, numericality: true, inclusion: { in: (1..100).map(&:to_s) }

  def register_type
    'my_spent_time'
  end

  def register_label
    -> { l(:label_my_spent_time) }
  end

  def register_specs
    { permission: :log_time }
  end

  def register_settings
    { days: nil }
  end
end
