# frozen_string_literal: true

# This file is part of the xmera Omnia Operations plugin.
#
# Copyright (C) 2020 - 2022 Liane Hampe <liane.hampe@xmera.de>, xmera.
#
# This plugin program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

require File.expand_path('../../test_helper', __dir__)

class NewsPresenterTest < ActiveSupport::TestCase
  include Redmine::I18n

  def setup
    @view = ActionController::Base.new.view_context
    @news = News.create(title: 'Latest news',
                        description: 'Lorem ipsum dolor sit amet, consectetur')
    @presenter = RedmineDashboards::NewsPresenter.new(@news, @view)
  end

  def teardown
    @presenter = nil
    @news = nil
    @view = nil
  end

  test 'should present summary' do
    text = 'Lorem ipsum'
    @news.summary = text
    expected = text
    current = @presenter.summary
    assert_equal expected, current
  end

  test 'should not present summary' do
    expected = ''
    current = @presenter.summary
    assert_equal expected, current
  end
end
