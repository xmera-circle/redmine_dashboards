# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2020 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/additionals>.
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

class DashboardContent
  include Redmine::I18n

  attr_accessor :user, :project

  DEFAULT_MAX_ENTRIES = 10
  RENDER_ASYNC_CACHE_EXPIRES_IN = 30

  class << self
    def types
      descendants.map { |dc| dc::TYPE_NAME }
    end
  end

  def initialize(attr = {})
    self.user = attr[:user].presence || User.current
    self.project = attr[:project].presence
  end

  # Returns the available blocks
  def available_blocks
    return @available_blocks if defined? @available_blocks

    available_blocks = registered_blocks.reject do |_name, attrs|
      specs = attrs[:specs]
      (specs.key?(:permission) && !user.allowed_to?(specs[:permission], project, global: true)) ||
        (specs.key?(:admin_only) && specs[:admin_only] && !user.admin?) ||
        (specs.key(:if) && !specs[:if].call(project))
    end

    @available_blocks = available_blocks.sort_by { |_name, attrs| attrs[:label] }.to_h
  end

  def registered_blocks
    all_block_instances.each_with_object({}) do |object, hash|
      block = object.instance
      attrs = block.attributes
      hash[attrs[:name]] = attrs
    end
  end

  def groups
    %w[top left right bottom]
  end

  # Returns the default layout for a new dashboard
  def default_layout
    {
      'left' => ['legacy_left'],
      'right' => ['legacy_right']
    }
  end

  def with_chartjs?
    false
  end

  def valid_block?(block, blocks_in_use = [])
    block.present? && block_options(blocks_in_use).map(&:last).include?(block)
  end

  def block_options(blocks_in_use = [])
    options = []
    available_blocks.each do |block, block_options|
      indexes = block_indexes(blocks_in_use, block)
      indexes.compact!

      occurs = indexes.size
      block_id = indexes.any? ? "#{block}__#{indexes.max + 1}" : block
      disabled = (occurs >= (available_blocks[block][:specs][:max_occurs] || 1))
      block_id = nil if disabled

      options << [block_options[:label], block_id]
    end
    options
  end

  def find_block(block_name)
    block_name.to_s =~ /\A(.*?)(__\d+)?\z/
    name = Regexp.last_match 1
    available_blocks.key?(name) ? find_block_instance_by(name) : nil
  end

  private

  def all_block_instances
    DashboardBlock.all
  end

  def find_block_instance_by(name)
    DashboardBlock.find_block(name)
  end

  def block_indexes(blocks_in_use, block_name)
    blocks_in_use.map do |item|
      Regexp.last_match(2).to_i if item =~ /\A#{block_name}(__(\d+))?\z/
    end
  end

  def logger
    Rails.logger
  end
end
