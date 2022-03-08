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

class BlockMacrosTest < Redmine::HelperTest
  include ApplicationHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  include ERB::Util
  include Rails.application.routes.url_helpers
  extend ActionView::Helpers::SanitizeHelper::ClassMethods

  def teardown
    button = ButtonBlock.instance
    button.link = nil
  end

  def test_button_macro
    text = "{{button(/documents, Documents)}}"
    current = textilizable(text)
    expected = '<a class="button" href="/documents">Documents</a>'
    assert_match expected, current
  end

  def test_button_macro_with_invalid_color
    text = "{{button(/documents, Documents, color=9e1030)}}"
    current = textilizable(text)
    expected = 'macro (Button: Color is invalid)'
    assert_match expected, current
  end

  def test_button_macro_with_valid_color
    text = "{{button(/documents, Documents, color=#9e1030)}}"
    assert textilizable(text)
  end

  def test_button_macro_with_invalid_external_option
    text = "{{button(/documents, Documents, external=x)}}"
    current = textilizable(text)
    expected = 'macro (Button: External needs to be 1)'
    assert_match expected, current
  end
end
