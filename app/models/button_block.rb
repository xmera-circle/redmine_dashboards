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

class ButtonBlock < DashboardBlock
  attr_accessor :text, :link, :color, :css

  validates :text, :link, presence: true
  validates :css, inclusion: { in: %w[inline centered] }
  validates :color, format: { with: /\A#([a-f0-9]{3}){,2}\z/i } # /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/i

  def register_type
    'button'
  end

  def register_label
    -> { l(:label_button) }
  end

  def register_specs
    { max_frequency: MAX_MULTIPLE_OCCURS,
      partial: 'dashboards/blocks/button' }
  end

  def register_settings
    { text: nil,
      link: nil,
      color: nil,
      css: nil }
  end
end
