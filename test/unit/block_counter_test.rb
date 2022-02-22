# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
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

require File.expand_path '../test_helper', __dir__

class BlockCounterTest < RedmineDashboards::TestCase
  def setup
    type = 'button',
    label = 'Button',
    active_blocks = %w[text button]
    @block_counter = counter(type, label, active_blocks)
  end

  def teardown
    @block_counter = nil
  end

  def test_respond_to_next_block_id
    assert @block_counter.respond_to? :next_block_id  
  end

  def test_number_of_block_id_is_zero
    current = @block_counter.send :number_of, 'button'
    expected = []
    assert_equal expected, current
  end

  def test_number_of_block_id_is_four
    current = @block_counter.send :number_of, 'button__4'
    expected = ['4']
    assert_equal expected, current
  end

  def test_block_frequency
    current = @block_counter.send :block_frequency
    expected = 0
    assert_equal expected, current
  end

  def test_block_disabled
    type = 'button',
    label = 'Button',
    active_blocks = %w[text button__11]
    block_counter = counter(type, label, active_blocks)
    assert block_counter.send :block_disabled?
  end

  private

  def counter(type, label, active_blocks)
    BlockCounter.new(type: type,
                     attrs: { type: type,
                              label: label,
                              specs: { max_frequency: 10,
                                       partial: 'dashboards/blocks/button' },
                              settings: { text: nil,
                                          link: nil,
                                          color: nil,
                                          css: nil } },
                     active_blocks: active_blocks)
  end
end