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

class DashboardBlock
  include ActiveModel::Model
  include Singleton
  include Redmine::I18n
  # Throws an error if a required method is not implemented
  class NotImplementedError < NoMethodError; end

  MAX_MULTIPLE_OCCURS = 8

  attr_reader :type, :specs, :settings

  delegate :key?, to: :attributes
  delegate :logger, to: :class

  def self.logger
    Rails.logger
  end

  ##
  # Collects all registered types of dashboard blocks
  #
  # @return [Array] An array of DashboardBlock child classes, i.e., all available
  #   types.
  #
  def self.all
    descendants
  end

  ##
  # Finds the registered block representative for a given block_id
  #
  # @params block_id [String] The unique identifier of a block item in a dashboard.
  # @return [Object] A DashboardBlock subclass of the corresponding block type or nil.
  #
  def self.find_block(block_id)
    klass = "#{sanitize_block_id(block_id).camelize}Block".safe_constantize
    return unless registered? klass

    klass.instance
  end

  ##
  # Sanitizes a given block id which may contain numbers. This is true for
  # blocks based on block types allowing :max_frequency > 1.
  #
  # @param block_id [String] The unique identifier of a block item in a dashboard.
  # @return [String] The block type incorporated into the block_id.
  #
  def self.sanitize_block_id(block_id)
    regex = /__\d+/
    block_id.split(regex)[0]
  end

  def self.registered?(block_klass)
    all.include? block_klass
  end

  ##
  # Initializes a block
  #
  # @param type [String] The block type, i.e., 'text', 'chart', etc.
  # @param label [String] The label of the block to be used in views.
  # @param specs [Hash] Some static specifications of the block such that :permission, :partial, :max_frequency, :async.
  # @param settings [Hash] Available settings for the block to be defined by the user.
  def initialize
    super
    @type = register_type
    @label = register_label
    @specs = register_specs
    @settings = register_settings
  end

  def [](attr_name)
    attr = attr_name.to_sym
    if key?(attr)
      attributes[attr]
    else
      attributes.dig(:specs, attr)
    end
  end

  def attributes
    { type: type,
      label: label,
      specs: specs,
      settings: settings }
  end

  def label
    @label.is_a?(Proc) ? @label.call : @label
  end

  def default_max_entries
    10
  end

  def register_type
    not_implemented(__method__)
  end

  def register_label
    not_implemented(__method__)
  end

  def register_specs
    not_implemented(__method__)
  end

  def register_settings
    not_implemented(__method__)
  end

  def validate_settings(settings, dashboard)
    update_settings(settings)
    return dashboard if valid?

    dashboard.errors.add(:base, "#{label}: #{errors.full_messages.join(', ')}")
    clear_settings
    errors.clear
    dashboard
  end

  def clear_settings
    settings&.each { |attr| clear_setting(attr) }
  end

  def forbidden?(user, project)
    not_allowed_to?(user, project) || not_admin?(user) || condition_not_met?(project)
  end

  private

  def not_implemented(method_name)
    klass = self.class.name
    raise NotImplementedError, "#{klass}##{method_name} needs to be implemented"
  end

  def not_allowed_to?(user, project)
    specs.key?(:permission) && !user.allowed_to?(specs[:permission], project, global: true)
  end

  def not_admin?(user)
    specs.key?(:admin_only) && specs[:admin_only] && !user.admin?
  end

  def condition_not_met?(project)
    specs.key(:if) && !specs[:if].call(project)
  end

  def update_settings(settings)
    assign_attributes(settings)
  end

  def clear_setting(attr)
    send("#{attr[0]}=", nil)
  end
end
