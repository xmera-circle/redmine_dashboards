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

module DashboardsSettingsHelper
  def with_default(arg, default)
    arg.presence || default
  end

  def dashboards_settings_colorfield(name, **options)
    dashboards_settings_input_field(:color_field_tag, name, **options)
  end

  def dashboards_settings_numberfield(name, **options)
    dashboards_settings_input_field :number_field_tag, name, **options
  end

  def dashboards_settings_textfield(name, **options)
    dashboards_settings_input_field :text_field_tag, name, **options
  end

  def dashboards_settings_passwordfield(name, **options)
    dashboards_settings_input_field :password_field_tag, name, **options
  end

  def dashboards_settings_urlfield(name, **options)
    dashboards_settings_input_field :url_field_tag, name, **options
  end

  def dashboards_settings_timefield(name, **options)
    dashboards_settings_input_field :time_field_tag, name, **options
  end

  def dashboards_settings_checkbox(name, **options)
    active_value = options.delete(:active_value).presence || (@settings.present? && @settings[name])
    tag_name = options.delete(:tag_name).presence || "settings[#{name}]"

    label_title = options.delete(:label).presence || l("label_#{name}")
    value = options.delete :value
    value_is_bool = options.delete :value_is_bool
    custom_value = if value.nil?
                     value = 1
                     false
                   else
                     value = 1 if value_is_bool
                     true
                   end

    checked = if custom_value && !value_is_bool
                active_value
              else
                RedmineDashboards.true? active_value
              end

    s = [label_tag(tag_name, label_title)]
    s << hidden_field_tag(tag_name, 0, id: nil) if !custom_value || value_is_bool
    s << check_box_tag(tag_name, value, checked, **options)
    safe_join s
  end

  def dashboards_settings_select(name, values, **options)
    tag_name = options.delete(:tag_name).presence || "settings[#{name}]"

    label_title = [options.delete(:label).presence || l("label_#{name}")]
    label_title << tag.span('*', class: 'required') if options[:required].present?

    safe_join [label_tag(tag_name, safe_join(label_title, ' ')),
               select_tag(tag_name, values, **options)]
  end

  def dashboards_settings_textarea(name, **options)
    label_title = options.delete(:label).presence || l("label_#{name}")
    value = if options.key? :value
              options.delete :value
            elsif @settings.present?
              @settings[name]
            end

    options[:class] = 'wiki-edit' unless options.key? :class
    options[:rows] = dashboards_textarea_cols value unless options.key? :rows

    safe_join [label_tag("settings[#{name}]", label_title),
               text_area_tag("settings[#{name}]", value, **options)]
  end

  private

  def dashboards_settings_input_field(tag_field, name, **options)
    tag_name = options.delete(:tag_name).presence || "settings[#{name}]"
    value = if options.key? :value
              options.delete :value
            elsif @settings.present?
              @settings[name]
            end

    label_title = [options.delete(:label).presence || l("label_#{name}")]
    label_title << tag.span('*', class: 'required') if options[:required].present?

    safe_join [label_tag(tag_name, safe_join(label_title, ' ')),
               send(tag_field, tag_name, value, **options)], ' '
  end
end
