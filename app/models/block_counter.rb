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
# Derives the next block id in dependence of already existing ids of active blocks.
#
# @note The BlockCounter stores no history of active blocks whereas it is
#  necessary to feed them in for every new instance.
#
class BlockCounter
  attr_reader :type, :attrs, :active_blocks

  def initialize(type:, attrs:, active_blocks:)
    @type = type
    @attrs = attrs
    @active_blocks = active_blocks
  end

  def next_block_id
    return nil if block_disabled?

    block_frequency >= 0 ? "#{type}__#{block_frequency + 1}" : type
  end

  private

  attr_accessor :frequency

  def block_disabled?
    block_frequency >= (attrs[:specs][:max_frequency] || 1)
  end

  def block_frequency
    return frequency if frequency

    indexes = active_blocks.map do |block_id|
      number_of(block_id)
    end
    values = indexes.flatten.compact
    self.frequency = values.empty? ? 0 : values.map(&:to_i).max
  end

  def number_of(block_id)
    block_id.scan(Regexp.new(/#{type}__(\d+)/)).flatten
  end
end
