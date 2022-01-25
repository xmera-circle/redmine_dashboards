# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2016 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/RedmineDashboards>.
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

require File.expand_path '../../test_helper', __FILE__

class ViewWelcomeIndexTopRenderOn < Redmine::Hook::ViewListener
  render_on :view_welcome_index_top, inline: '<div class="test">Example text</div>'
end

class ViewWelcomeIndexBottomRenderOn < Redmine::Hook::ViewListener
  render_on :view_welcome_index_bottom, inline: '<div class="test">Example text</div>'
end

class ViewDashboardTopRenderOn < Redmine::Hook::ViewListener
  render_on :view_dashboard_top, inline: '<div class="test">Example text</div>'
end

class ViewDashboardBottomRenderOn < Redmine::Hook::ViewListener
  render_on :view_dashboard_bottom, inline: '<div class="test">Example text</div>'
end

class WelcomeControllerTest < RedmineDashboards::ControllerTest
  fixtures :projects, :news, :users, :members,
           :dashboards, :dashboard_roles

  def setup
    Setting.default_language = 'en'
    User.current = nil
  end

  def test_show_with_left_text_block
    @request.session[:user_id] = 4
    get :index

    assert_response :success
    assert_select 'div#list-left div#block-text', text: /example text/
  end

  def test_show_with_right_text_block
    @request.session[:user_id] = 4
    get :index

    assert_response :success
    assert_select 'div#list-right div#block-text__1', text: /example text/
  end

  def test_show_with_hook_view_welcome_index_top
    Redmine::Hook.add_listener ViewWelcomeIndexTopRenderOn
    @request.session[:user_id] = 4
    get :index

    assert_select 'div.test', text: 'Example text'
  end

  def test_show_with_hook_view_welcome_index_bottom
    Redmine::Hook.add_listener ViewWelcomeIndexBottomRenderOn
    @request.session[:user_id] = 4
    get :index

    assert_select 'div.test', text: 'Example text'
  end

  def test_show_with_hook_view_dashboard_top
    Redmine::Hook.add_listener ViewDashboardTopRenderOn
    @request.session[:user_id] = 4
    get :index

    assert_select 'div.test', text: 'Example text'
  end

  def test_show_with_hook_view_dashboard_bottom
    Redmine::Hook.add_listener ViewDashboardBottomRenderOn
    @request.session[:user_id] = 4
    get :index

    assert_select 'div.test', text: 'Example text'
  end

  def test_index_with_invalid_dashboard
    get :index,
        params: { dashboard_id: 444 }

    assert_response :missing
  end
end
