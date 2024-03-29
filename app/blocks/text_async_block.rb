# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2022-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

class TextAsyncBlock < DashboardBlock
  attr_accessor :title, :text, :css, :user_id, :user_is_admin

  validates :text, presence: true
  validates :css, inclusion: { in: BlockStyles.position_classes }, allow_nil: true

  def register_type
    'text_async'
  end

  def register_label
    -> { l(:label_text_async) }
  end

  def register_specs
    { max_frequency: MAX_MULTIPLE_OCCURS,
      async: { required_settings: %i[text],
               partial: 'dashboards/blocks/text_async' } }
  end

  def register_settings
    { title: nil,
      text: nil,
      css: nil,
      user_id: nil,
      user_is_admin: nil }
  end
end
