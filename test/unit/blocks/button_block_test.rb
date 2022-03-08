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

require File.expand_path '../../test_helper', __dir__

class ButtonBlockValidationTest < RedmineDashboards::TestCase
  def setup
    @button_block = ButtonBlock.instance
    @button_block.text = 'Button'
    @button_block.link = '/issues'
    @button_block.css = 'inline'
    @button_block.color = '#83BF40'
  end

  def teardown
    @button_block.text = nil
    @button_block.link = nil
    @button_block.css = nil
    @button_block.color = nil
    @button_block = nil
  end

  def test_valid_button
    assert @button_block.valid?, @button_block.link
  end

  def test_invalid_button_text
    @button_block.text = nil
    assert @button_block.invalid?
  end

  def test_invalid_link
    @button_block.external = true
    @button_block.link = 'mailto:'
    assert @button_block.invalid?
  end

  def test_valid_link_without_frontslash
    @button_block.external = false
    @button_block.link = +'projects'
    expected = '/projects'
    @button_block.valid?
    current = @button_block.link
    assert_equal expected, current
  end

  def test_invalid_css
    @button_block.css = 'invalid'
    assert @button_block.invalid?
  end

  def test_invalid_button_color
    @button_block.color = '83BF40'
    assert @button_block.invalid?
  end
end
