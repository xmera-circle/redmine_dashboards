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
  # include ActiveModel::AttributeMethods
  # include ActiveModel::Validations
  include ActiveModel::Model
  include Redmine::I18n
  include Singleton
  # Throws an error if a required method is not implemented
  class NotImplementedError < NoMethodError; end

  MAX_MULTIPLE_OCCURS = 8

  attr_accessor :name, :label, :specs, :settings

  delegate :key?, to: :attributes

  ##
  # Collects all child classes of DashboardBlock
  #
  # @return [Array] An array of DashboardBlock child classes
  #
  def self.all
    descendants
  end

  def self.find(name)
    "#{name.camelize}Block".constantize.instance
  end

  ##
  # Initializes a block
  # @param name [String] The name of the block to be used as key.
  # @param label [String] The label of the block to be used in the view.
  # @param specs [Hash] Some static specifications of the block such that :permission, :partial, :max_occurs, :async.
  # @param settings [Hash] Available settings for the block to be defined by the user.
  def initialize
    super
    @name = register_name
    @label = register_label
    @specs = register_specs
    @settings = register_settings
  end

  def register_name
    not_implemented(__method__) # or ''
  end

  def register_label
    not_implemented(__method__) # or ''
  end

  def register_specs
    not_implemented(__method__) # or {}
  end

  def register_settings
    not_implemented(__method__) # or {}
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
    { name: name,
      label: label.call,
      specs: specs,
      settings: settings }
  end

  def validate
    # require label to be given?
    not_implemented(__method__)
  end

  private

  def not_implemented(method_name)
    klass = self.class.name
    raise NotImplementedError, "#{klass}##{method_name} needs to be implemented"
  end
end
