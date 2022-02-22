# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2016 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/additionals>.
#
# Copyright (C) 2021 - 2022 Liane Hampe <liaham@xmera.de>, xmera.
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
# Collects local variables for block partial out of the given data.
#
class BlockPartial
  def initialize(block:, settings:, dashboard:, params:)
    @block = block
    @default_locals = { dashboard: dashboard,
                        settings: settings,
                        block_id: block_id,
                        block_object: block_object,
                        user: User.current }
    @params = params
    @current_locals = {}
  end

  def locals
    [default_locals, query_locals, async_locals].inject(&:merge)
  end

  private

  attr_reader :block, :params, :default_locals, :current_locals

  def query_locals
    return {} unless query_block

    current_locals[:query_block] = query_block
    current_locals[:klass] = query_block[:class]
    current_locals
  end

  def query_block
    block_object[:query_block]
  end

  def async_locals
    return {} unless async_block

    current_locals[:async] = async_block
    current_locals[:async][:unique_params] = [Redmine::Utils.random_hex(16)] if params[:refresh].present?
    current_locals
  end

  def async_block
    block_object[:async]
  end

  def block_id
    block[:id]
  end

  def block_object
    block[:object]
  end
end
