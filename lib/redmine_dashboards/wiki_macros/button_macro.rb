# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2021-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

module RedmineDashboards
  module WikiMacros
    ##
    # The button macro uses the ButtonBlock class and the corresponding
    # partial. All settings are supported, except for css classes.
    #
    module ButtonMacro
      Redmine::WikiFormatting::Macros.register do
        desc <<~DESCRIPTION
          Displays a link as button. Examples:

          {{button(link, text)}}
          {{button(link, text, external=1)}} -- to mark a link as external
          {{button(link, text, color=#9e1030)}} -- to set an individual color
        DESCRIPTION

        macro :button do |_obj, args|
          args, options = extract_macro_options(args, :external, :color, :position)
          raise t(:error_external_not_in_list) unless ['', '1', '0'].include? options[:external].to_s

          link = args.first
          text = args.last
          options[:color] ||= '#a8a7a7'
          options[:position] = 'unset'
          options[:css] = options.delete(:position)
          settings = { link: link, text: text }.merge(options)
          block = ButtonBlock.instance
          block_id = block.random_id
          valid = block.validate_settings(settings, NullDashboard.new)
          raise valid.errors.full_messages.join(', ') if valid.errors.any?

          tag.div id: "block-#{block_id}" do
            render(partial: 'dashboards/blocks/button_block',
                   locals: { settings: settings, block_id: block_id })
          end
        end
      end
    end
  end
end
