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

require 'forwardable'

class ButtonBlock < DashboardBlock
  extend Forwardable
  attr_accessor :text, :link, :external, :color, :css

  def_delegator RedmineDashboards, :true?

  validates :text, :link, presence: true
  validates :link, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), if: :external?
  validate :internal_link, unless: :external?
  validates :css, inclusion: { in: BlockStyles.position_classes }, allow_nil: true
  validates :color, format: { with: /\A#([a-f0-9]{3}){,2}\z/i }

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
      external: nil,
      color: nil,
      css: nil }
  end

  def random_id
    "#{type}__#{SecureRandom.alphanumeric}"
  end

  private

  def external?
    true? external
  end

  ##
  # The validation call back above is misused here
  # in order to make sure the relative link starts
  # with a frontslash.
  #
  def internal_link
    return true unless link

    link.prepend('/') unless link.start_with?('/')
    link
  end
end
