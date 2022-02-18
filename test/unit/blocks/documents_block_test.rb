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

class DocumentsBlockValidationTest < RedmineDashboards::TestCase
  def setup
    @documents_block = DocumentsBlock.instance
    @documents_block.max_entries = '5'
  end

  def teardown
    @documents_block = nil
  end

  def test_valid_documents
    assert @documents_block.valid?
  end

  def test_invalid_max_entries
    @documents_block.max_entries = '101'
    assert @documents_block.invalid?
  end
end
