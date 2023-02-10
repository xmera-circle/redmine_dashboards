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

class BlockStyles
  extend Redmine::I18n
  class << self
    def position_options_for_select
      positions.invert.to_a
    end

    def position_classes
      positions.keys.map(&:to_s)
    end

    private

    def positions
      { unset: l(:label_position_unset),
        inline: l(:label_position_inline),
        full_width: l(:label_position_full_width),
        left: l(:label_position_left),
        right: l(:label_position_right),
        center: l(:label_position_center) }
    end
  end
end
