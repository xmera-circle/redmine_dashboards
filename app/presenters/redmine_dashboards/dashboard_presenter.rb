# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2022-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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
  ##
  # Prepares all dashboard components to be ready for rendering.
  #
  class DashboardPresenter < AdvancedPluginHelper::BasePresenter
    presents :dashboard

    def headline
      name = [l(:label_home)]
      name << dashboard.name if dashboard&.always_expose? || (dashboard.present? && !dashboard.system_default?)
      safe_join name, RedmineDashboards::SEPARATOR
    end

    def css_classes
      classes = ['dashboard', dashboard.dashboard_type.underscore, "dashboard-#{dashboard.id}"]
      safe_join classes, ' '
    end

    def render_sidebar_dashboards(project = nil)
      dashboards = sidebar_dashboards(project)
      out = [dashboard_links(l(:label_my_dashboard_plural),
                             if User.current.allowed_to?(:manage_own_dashboards, project,
                                                         global: true)
                               dashboards.select(&:own?)
                             else
                               []
                             end,
                             project),
             dashboard_links(l(:label_shared_dashboard_plural),
                             dashboards.select(&:non_private?),
                             project)]

      out << dashboard_info if dashboard.always_expose? || !dashboard.system_default

      safe_join out
    end

    def render_dashboard_actionlist(project = nil)
      dashboards = sidebar_dashboards(project)
      base_css = 'icon icon-dashboard'
      out = []

      dashboards.select!(&:visible?)
      dashboards.each do |board|
        css_class = base_css
        dashboard_name = "#{l :label_dashboard}: #{board.name}"
        out << if board.id == dashboard.id
                 link_to dashboard_name, '#',
                         onclick: 'return false;',
                         class: "#{base_css} disabled"
               else
                 dashboard_link board,
                                class: css_class,
                                title: l(:label_change_to_dashboard),
                                name: dashboard_name
               end
      end

      safe_join out
    end

    def sidebar_action_toggle(enabled)
      link_to sidebar_action_toggle_label(enabled),
              dashboard_link_path(dashboard, enable_sidebar: !enabled),
              class: 'icon icon-sidebar'
    end

    def delete_dashboard_link(url)
      options = { method: :delete,
                  data: { confirm: l(:text_are_you_sure) },
                  class: 'icon icon-del' }

      link_to l(:button_dashboard_delete), url, options
    end

    # Returns the select tag used to add or remove a block
    def dashboard_block_select_tag
      blocks_in_use = dashboard.layout.values.flatten
      options = tag.option l(:label_add_dashboard_block), value: ''
      dashboard.content.block_options(blocks_in_use).each do |label, block_id|
        options << tag.option(label, value: block_id, disabled: block_id.blank?)
      end
      select_tag  'block_id',
                  options,
                  id: 'block-select',
                  class: 'dashboard-block-select',
                  onchange: "$('#block-form').submit();"
    end

    # Renders the blocks
    def render_dashboard_blocks(block_ids, _options = {})
      s = ''.html_safe

      if block_ids.present?
        block_ids.each do |block_id|
          s << render_dashboard_block(block_id).to_s
        end
      end
      s
    end

    # Renders a single block
    def render_dashboard_block(block_id, overwritten_settings = {})
      return unless User.current.logged?

      block_object = dashboard.content.find_block(block_id)
      unless block_object
        Rails.logger.info "Unknown block \"#{block_id}\" found in #{dashboard.name} (id=#{dashboard.id})"
        return
      end

      content = render_dashboard_block_content(block_id, block_object, dashboard, overwritten_settings)
      return if content.blank?

      if dashboard.editable?
        icons = []
        if block_object[:no_settings].blank? &&
           (!block_object.key?(:with_settings_if) || block_object[:with_settings_if].call(@project))
          icons << link_to_function(l(:label_options),
                                    "$('##{block_id}-settings').toggle();",
                                    class: 'icon-only icon-settings',
                                    title: l(:label_options))
        end
        icons << tag.span('', class: 'icon-only icon-sort-handle sort-handle', title: l(:button_move))
        icons << delete_link(remove_block_dashboard_path(dashboard, block_id: block_id),
                             method: :post,
                             remote: true,
                             class: 'icon-only icon-close',
                             title: l(:button_delete))

        content = tag.div(safe_join(icons), class: 'contextual') + content
      end
      css = dashboard.layout_settings[block_id].fetch(:css, 'unset')
      tag.div content, class: "mypage-box #{css}", id: "block-#{block_id}"
    end

    def user_options_for_select(project, permission = nil)
      scope = project.present? ? project.users.visible : User.active.visible
      scope = scope.with_permission permission, project unless permission.nil?
      users = scope.sorted.to_a

      unless dashboard.nil?
        current_user_found = users.detect { |u| u.id == dashboard.user_id_was }
        if current_user_found.blank?
          current_user = User.find_by id: dashboard.user_id_was
          users << current_user if current_user
        end
      end

      s = []
      return s unless users.any?

      s << tag.option("<< #{l :label_me} >>", value: User.current.id) if users.include? User.current

      if dashboard.nil?
        s << options_from_collection_for_select(users, 'id', 'name')
      else
        if dashboard.user && users.exclude?(dashboard.user)
          s << tag.option(dashboard.user, value: dashboard.user_id,
                                          selected: true)
        end
        s << options_from_collection_for_select(users, 'id', 'name', dashboard.user_id)
      end
      safe_join s
    end

    private

    def sidebar_dashboards(project = nil)
      scope = Dashboard.visible.includes [:user]

      scope = if project.present?
                scope = scope.project_only
                scope
                  .where(project_id: project.id)
                  .or(scope.where(project_id: nil))
              else
                scope.where dashboard_type: dashboard.dashboard_type
              end
      scope.sorted.to_a
    end

    def dashboard_info
      tag.div class: 'active-dashboards' do
        out = [tag.h3(l(:label_active_dashboard)),
               tag.ul do
                 concat tag.li "#{l :field_name}: #{dashboard.name}"
                 concat tag.li safe_join([l(:field_user), link_to_user(dashboard.user)], ': ')
                 concat tag.li "#{l :field_created_on}: #{format_time dashboard.created_at}"
                 concat tag.li "#{l :field_updated_on}: #{format_time dashboard.updated_at}"
               end]

        if dashboard.description.present?
          out << tag.div(textilizable(dashboard, :description, inline_attachments: false),
                         class: 'dashboard-description')
        end

        safe_join out
      end
    end

    def dashboard_links(title, dashboards, _project)
      return '' unless dashboards.any?

      tag.h3(title, class: 'dashboards') +
        tag.ul(class: 'dashboards') do
          dashboards.each do |board|
            selected = board.id == if params[:dashboard_id].present?
                                     params[:dashboard_id].to_i
                                   else
                                     board.id
                                   end

            css = +'dashboard'
            css << ' selected' if selected
            link = [dashboard_link(board, class: css)]
            li_class = 'global' if board.system_default?

            concat tag.li safe_join(link), class: li_class
          end
        end
    end

    def dashboard_link(given_dashboard, **options)
      if options[:title].blank? && given_dashboard.public?
        user = if given_dashboard.user_id == User.current.id
                 l :label_me
               else
                 given_dashboard.user
               end
        options[:title] = l :label_dashboard_user, name: user
      end

      name = options.delete(:name) || given_dashboard.name
      link_to name, dashboard_link_path(given_dashboard), options
    end

    def sidebar_action_toggle_label(enabled)
      enabled ? l(:label_disable_sidebar) : l(:label_enable_sidebar)
    end
  end
end
