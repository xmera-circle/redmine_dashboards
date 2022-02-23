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

module DashboardsHelper
  def dashboard_async_cache(dashboard, block_id, async, settings, &content_block)
    cache render_async_cache_key(dashboard_async_blocks_path(dashboard.async_params(block_id, async, settings))),
          expires_in: async[:cache_expires_in] || DashboardContent::RENDER_ASYNC_CACHE_EXPIRES_IN,
          skip_digest: true, &content_block
  end

  def dashboard_sidebar?(params)
    enabled = params['enable_sidebar']
    return false if enabled.blank?

    RedmineDashboards.true? enabled
  end

  def welcome_overview_name(dashboard = nil)
    name = [l(:label_home)]
    name << dashboard.name if dashboard&.always_expose? || (dashboard.present? && !dashboard.system_default?)

    safe_join name, RedmineDashboards::SEPARATOR
  end

  def dashboard_css_classes(dashboard)
    classes = ['dashboard', dashboard.dashboard_type.underscore, "dashboard-#{dashboard.id}"]
    safe_join classes, ' '
  end

  def sidebar_dashboards(dashboard, project = nil)
    scope = Dashboard.visible.includes [:author]

    scope = if project.present?
              scope = scope.project_only
              scope.where(project_id: project.id)
                   .or(scope.where(project_id: nil))
            else
              scope.where dashboard_type: dashboard.dashboard_type
            end

    scope.sorted.to_a
  end

  def render_dashboard_actionlist(active_dashboard, project = nil)
    dashboards = sidebar_dashboards active_dashboard, project
    base_css = 'icon icon-dashboard'
    out = []

    dashboards.select!(&:public?) unless User.current.allowed_to? :save_dashboards, project, global: true
    dashboards.each do |dashboard|
      css_class = base_css
      dashboard_name = "#{l :label_dashboard}: #{dashboard.name}"
      out << if dashboard.id == active_dashboard.id
               link_to dashboard_name, '#',
                       onclick: 'return false;',
                       class: "#{base_css} disabled"
             else
               dashboard_link dashboard,
                              class: css_class,
                              title: l(:label_change_to_dashboard),
                              name: dashboard_name
             end
    end

    safe_join out
  end

  def render_sidebar_dashboards(dashboard, project = nil)
    dashboards = sidebar_dashboards dashboard, project
    out = [dashboard_links(l(:label_my_dashboard_plural),
                           dashboard,
                           if User.current.allowed_to?(:save_dashboards, project,
                                                       global: true)
                             dashboards.select(&:private?)
                           else
                             []
                           end,
                           project),
           dashboard_links(l(:label_shared_dashboard_plural),
                           dashboard,
                           dashboards.select(&:public?),
                           project)]

    out << dashboard_info(dashboard) if dashboard.always_expose? || !dashboard.system_default

    safe_join out
  end

  def dashboard_info(dashboard)
    tag.div class: 'active-dashboards' do
      out = [tag.h3(l(:label_active_dashboard)),
             tag.ul do
               concat tag.li "#{l :field_name}: #{dashboard.name}"
               concat tag.li safe_join([l(:field_author), link_to_user(dashboard.author)], ': ')
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

  def dashboard_links(title, active_dashboard, dashboards, _project)
    return '' unless dashboards.any?

    tag.h3(title, class: 'dashboards') +
      tag.ul(class: 'dashboards') do
        dashboards.each do |dashboard|
          selected = dashboard.id == if params[:dashboard_id].present?
                                       params[:dashboard_id].to_i
                                     else
                                       active_dashboard.id
                                     end

          css = +'dashboard'
          css << ' selected' if selected
          link = [dashboard_link(dashboard, class: css)]
          li_class = 'global' if dashboard.system_default?

          concat tag.li safe_join(link), class: li_class
        end
      end
  end

  def dashboard_link(dashboard, **options)
    if options[:title].blank? && dashboard.public?
      author = if dashboard.author_id == User.current.id
                 l :label_me
               else
                 dashboard.author
               end
      options[:title] = l :label_dashboard_author, name: author
    end

    name = options.delete(:name) || dashboard.name
    link_to name, dashboard_link_path(dashboard), options
  end

  def sidebar_action_toggle(enabled, dashboard)
    link_to sidebar_action_toggle_label(enabled),
            dashboard_link_path(dashboard, enable_sidebar: !enabled),
            class: 'icon icon-sidebar'
  end

  def sidebar_action_toggle_label(enabled)
    enabled ? l(:label_disable_sidebar) : l(:label_enable_sidebar)
  end

  def delete_dashboard_link(url)
    options = { method: :delete,
                data: { confirm: l(:text_are_you_sure) },
                class: 'icon icon-del' }

    link_to l(:button_dashboard_delete), url, options
  end

  # Returns the select tag used to add or remove a block
  def dashboard_block_select_tag(dashboard)
    blocks_in_use = dashboard.layout.values.flatten
    options = tag.option l(:label_add_dashboard_block), value: ''
    dashboard.content.block_options(blocks_in_use).each do |label, block_id|
      options << tag.option(label, value: block_id, disabled: block_id.blank?)
    end
    select_tag 'block_id',
               options,
               id: 'block-select',
               class: 'dashboard-block-select',
               onchange: "$('#block-form').submit();"
  end

  # Renders the blocks
  def render_dashboard_blocks(block_ids, dashboard, _options = {})
    s = ''.html_safe

    if block_ids.present?
      block_ids.each do |block_id|
        s << render_dashboard_block(block_id, dashboard).to_s
      end
    end
    s
  end

  # Renders a single block
  def render_dashboard_block(block_id, dashboard, overwritten_settings = {})
    return unless User.current.logged?

    block_object = dashboard.content.find_block block_id
    unless block_object
      Rails.logger.info "Unknown block \"#{block_id}\" found in #{dashboard.name} (id=#{dashboard.id})"
      return
    end

    content = render_dashboard_block_content block_id, block_object, dashboard, overwritten_settings
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

  def build_dashboard_partial_locals(block_id, block_object, settings, dashboard)
    partial = BlockPartial.new(block: { id: block_id, object: block_object },
                               settings: settings,
                               dashboard: dashboard,
                               params: params)
    partial.locals
  end

  def dashboard_async_required_settings?(settings, async)
    return true if async[:required_settings].blank?
    return false if settings.blank?

    async[:required_settings].each do |required_setting|
      return false if settings.exclude?(required_setting) || settings[required_setting].blank?
    end

    true
  end

  def dashboard_query_list_block_title(query, query_block, project)
    title = []
    title << query.project if project.nil? && query.project
    title << query_block[:label].call

    title << if query_block[:with_project]
               link_to query.name, send(query_block[:link_helper], project, query.as_params)
             else
               link_to query.name, send(query_block[:link_helper], query.as_params)
             end

    safe_join title, RedmineDashboards::SEPARATOR
  end

  def dashboard_query_list_block_alerts(dashboard, query, block_object)
    return if dashboard.visibility == Dashboard::VISIBILITY_PRIVATE

    title = if query.visibility == Query::VISIBILITY_PRIVATE
              l :alert_only_visible_by_yourself
            elsif block_object.key?(:admin_only) && block_object[:admin_only]
              l :alert_only_visible_by_admins
            end

    return unless title

    content_tag :div, '', title: title, class: 'icon-only icon-warning attention', style: 'display: inline-block'
  end

  def render_legacy_left_block(_block_id, _block_object, _settings, _dashboard)
    call_hook :view_welcome_index_left
  end

  def render_legacy_right_block(_block_id, _block_object, _settings, _dashboard)
    call_hook :view_welcome_index_right
  end

  # copied from my_helper
  def render_documents_block(block_id, block_object, settings, dashboard)
    max_entries = settings.fetch(:max_entries, block_object.default_max_entries)

    scope = Document.visible
    scope = scope.where project: dashboard.project if dashboard.project

    documents = scope.order(created_on: :desc)
                     .limit(max_entries)
                     .to_a

    render partial: 'dashboards/blocks/documents',
           locals: { block_id: block_id,
                     max_entries: max_entries,
                     documents: documents }
  end

  def render_news_block(block_id, block_object, settings, dashboard)
    max_entries = settings.fetch(:max_entries, block_object.default_max_entries)

    news = if dashboard.content_project.nil?
             News.latest User.current, max_entries
           else
             dashboard.content_project
                      .news
                      .limit(max_entries)
                      .includes(:author, :project)
                      .reorder(created_on: :desc)
                      .to_a
           end

    render partial: 'dashboards/blocks/news', locals: { block_id: block_id,
                                                        max_entries: max_entries,
                                                        news: news }
  end

  def render_my_spent_time_block(block_id, block_object, settings, dashboard)
    days = settings[:days].to_i
    days = 7 if days < 1 || days > 365

    scope = TimeEntry.where user_id: User.current.id
    scope = scope.where project_id: dashboard.content_project.id unless dashboard.content_project.nil?

    entries_today = scope.where spent_on: User.current.today
    entries_days = scope.where spent_on: User.current.today - (days - 1)..User.current.today

    render partial: 'dashboards/blocks/my_spent_time',
           locals: { block_id: block_id,
                     block_object: block_object,
                     entries_today: entries_today,
                     entries_days: entries_days,
                     days: days }
  end

  def activity_dashboard_data(block_object, settings, dashboard)
    max_entries = settings.fetch(:max_entries, block_object.default_max_entries).to_i
    user = User.current
    options = {}
    options[:author] = user if RedmineDashboards.true? settings[:me_only]
    options[:project] = dashboard.content_project if dashboard.content_project.present?

    Redmine::Activity::Fetcher.new(user, options)
                              .events(nil, nil, limit: max_entries)
                              .group_by { |event| user.time_to_date event.event_datetime }
  end

  def dashboard_feed_catcher(url, max_entries)
    feed = { items: [], valid: false }
    return feed if url.blank?

    cnt = 0
    max_entries = max_entries.present? ? max_entries.to_i : 10

    begin
      URI.parse(url).open do |rss_feed|
        rss = RSS::Parser.parse rss_feed
        rss.items.each do |item|
          cnt += 1
          feed[:items] << { title: item.title.try(:content)&.presence || item.title,
                            link: item.link.try(:href)&.presence || item.link }
          break if cnt >= max_entries
        end
      end
    rescue StandardError => e
      Rails.logger.info "dashboard_feed_catcher error for #{url}: #{e}"
      return feed
    end

    feed[:valid] = true

    feed
  end

  def dashboard_feed_title(title, block_object)
    title.presence || block_object[:label]
  end

  def options_for_query_select(klass, project, selected = nil)
    tag.option + options_from_collection_for_select(queries(klass, project), :id, :name, selected)
  end

  def grouped_options_for_query_select(klass, project, selected = nil)
    all_queries = queries(klass, project)
    group = { "#{l(:label_my_queries)}": all_queries.select(&:is_private?).pluck(:name, :id),
              "#{l(:label_query_plural)}": all_queries.reject(&:is_private?).pluck(:name, :id) }

    tag.option + grouped_options_for_select(group.to_a, selected)
  end

  private

  ##
  # sidebar_queries cannot be used because descendant classes are included
  # this changes on class loading
  # queries = klass.visible.global_or_on_project(@project).sorted.to_a
  #
  def queries(klass, project)
    klass.visible
         .global_or_on_project(project)
         .where(type: klass.to_s)
         .sorted.to_a
  end

  # Renders a single block content
  def render_dashboard_block_content(block_id, block_object, dashboard, overwritten_settings = {})
    settings = dashboard.layout_settings block_id
    settings = settings.merge overwritten_settings if overwritten_settings.present?
    partial = block_object[:partial]
    partial_locals = build_dashboard_partial_locals block_id, block_object, settings, dashboard

    if block_object[:query_block] || block_object[:async]
      render partial: 'dashboards/blocks/async', locals: partial_locals
    elsif partial
      begin
        render partial: partial, locals: partial_locals
      rescue ActionView::MissingTemplate
        Rails.logger.warn "Partial \"#{partial}\" missing for block \"#{block_id}\" found in #{dashboard.name} (id=#{dashboard.id})"
        nil
      end
    else
      send "render_#{block_object[:type]}_block",
           block_id,
           block_object,
           settings,
           dashboard
    end
  end

  def resently_used_dashboard_save(dashboard, project = nil)
    user = User.current
    dashboard_type = dashboard.dashboard_type
    recently_id = user.pref.recently_used_dashboard dashboard_type, project
    return if recently_id == dashboard.id || user.anonymous?

    user.pref.recently_used_dashboards[dashboard_type] = dashboard.id
    user.pref.save
  end

  ##
  # Copied from Redmine ReportsHelper module
  #
  def aggregate(data, criteria)
    a = 0
    data&.each do |row|
      match = 1
      criteria&.each do |k, v|
        next if (row[k].to_s == v.to_s) ||
                (k == 'closed' &&
                  (v.zero? ? ['f', false] : ['t', true]).include?(row[k]))

        match = 0
      end
      a += row['total'].to_i if match == 1
    end
    a
  end
end
