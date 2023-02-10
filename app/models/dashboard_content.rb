# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2020 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
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

require 'forwardable'

##
# Provides dashboard content related data with reference to the dashboard
# layout and its blocks.
#
class DashboardContent
  include Redmine::I18n
  extend Forwardable

  def_delegators :block_klass, :all, :find_block
  attr_reader :user, :project, :block_klass

  RENDER_ASYNC_CACHE_EXPIRES_IN = 30

  class << self
    def types
      descendants.map { |klass| klass::TYPE_NAME }
    end
  end

  def initialize(attr = {})
    self.user = attr[:user].presence || User.current
    self.project = attr[:project].presence
    self.block_klass = attr[:block_klass].presence
  end

  ##
  # Returns the layout groups which determine the drop areas in the layout.
  #
  def groups
    %w[top left-left left-center right-center right-right middle left right bottom]
  end

  ##
  # Returns the default layout for a new dashboard.
  #
  def default_layout
    {
      'left' => %w[welcome],
      'right' => %w[news]
    }
  end

  def with_chartjs?
    available_blocks.any? { |_block_type, attrs| attrs[:specs][:chartjs] }
  end

  ##
  # Checks the validity of a given block id by comparing it with the set
  # of available block ids.
  #
  def valid_block?(block_id, blocks_in_use = [])
    return false if block_id.blank?

    available_block_ids(blocks_in_use).include?(block_id)
  end

  ##
  # Prepares the block options for select as provided on top of the dashboard
  # page.
  #
  def block_options(blocks_in_use = [])
    options = []
    available_blocks.each do |block_type, block_attrs|
      counter = BlockCounter.new(type: block_type, attrs: block_attrs, active_blocks: blocks_in_use)
      options << [block_attrs[:label], counter.next_block_id]
    end
    options
  end

  private

  attr_writer :user, :project, :block_klass
  attr_accessor :allowed_blocks

  ##
  # Retrieves an array of block_ids from blocks already in use.
  #
  def available_block_ids(blocks_in_use)
    block_options(blocks_in_use).map(&:last)
  end

  ##
  # Retrieves all blocks available for a given user and project.
  #
  def available_blocks
    return allowed_blocks if allowed_blocks

    blocks = all.each_with_object({}) do |klass, hash|
      assign_block_if_available(klass, hash)
    end

    self.allowed_blocks = blocks.sort_by { |_block_type, attrs| attrs[:label] }.to_h
  end

  ##
  # Adds a block to the hash of available blocks if and only if the user has the
  # permission to read the block contents.
  #
  def assign_block_if_available(klass, hash)
    instance = block(klass)
    return if instance.forbidden?(user, project)

    hash[instance.type] = instance.attributes
  end

  def block(klass)
    klass.instance
  end

  def logger
    Rails.logger
  end
end
