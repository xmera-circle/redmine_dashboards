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

module DashboardsQueriesHelper
  def dashboards_query_session_key(object_type)
    "#{object_type}_query".to_sym
  end

  def dashboards_retrieve_query(object_type, user_filter: nil)
    session_key = dashboards_query_session_key object_type
    query_class = Object.const_get "#{object_type.camelcase}Query"
    if params[:query_id].present?
      dashboards_load_query_id  query_class,
                                session_key,
                                params[:query_id],
                                object_type,
                                user_filter: user_filter
    elsif api_request? ||
          params[:set_filter] ||
          session[session_key].nil? ||
          session[session_key][:project_id] != (@project ? @project.id : nil)
      # Give it a name, required to be valid
      @query = query_class.new name: '_'
      @query.project = @project
      @query.user_filter = user_filter if user_filter
      @query.build_from_params params
      session[session_key] = { project_id: @query.project_id }
      # session has a limit to 4k, we have to use a cache for it for larger data
      Rails.cache.write(dashboards_query_cache_key(object_type),
                        filters: @query.filters,
                        group_by: @query.group_by,
                        column_names: @query.column_names,
                        totalable_names: @query.totalable_names,
                        sort_criteria: params[:sort].presence || @query.sort_criteria.to_a)
    else
      # retrieve from session
      @query = query_class.find_by id: session[session_key][:id] if session[session_key][:id]
      session_data = Rails.cache.read dashboards_query_cache_key(object_type)
      @query ||= query_class.new(name: '_',
                                 filters: session_data.nil? ? nil : session_data[:filters],
                                 group_by: session_data.nil? ? nil : session_data[:group_by],
                                 column_names: session_data.nil? ? nil : session_data[:column_names],
                                 totalable_names: session_data.nil? ? nil : session_data[:totalable_names],
                                 sort_criteria: params[:sort].presence || (session_data.nil? ? nil : session_data[:sort_criteria]))
      @query.project = @project
      if params[:sort].present?
        @query.sort_criteria = params[:sort]
        # we have to write cache for sort order
        Rails.cache.write(dashboards_query_cache_key(object_type),
                          filters: @query.filters,
                          group_by: @query.group_by,
                          column_names: @query.column_names,
                          totalable_names: @query.totalable_names,
                          sort_criteria: params[:sort])
      elsif session_data.present?
        @query.sort_criteria = session_data[:sort_criteria]
      end
    end
  end

  def dashboards_load_query_id(query_class, session_key, query_id, object_type, user_filter: nil)
    scope = query_class.where project_id: nil
    scope = scope.or query_class.where(project_id: @project.id) if @project
    @query = scope.find query_id
    raise ::Unauthorized unless @query.visible?

    @query.project = @project
    @query.user_filter = user_filter if user_filter
    session[session_key] = { id: @query.id, project_id: @query.project_id }

    @query.sort_criteria = params[:sort] if params[:sort].present?
    # we have to write cache for sort order
    Rails.cache.write(dashboards_query_cache_key(object_type),
                      filters: @query.filters,
                      group_by: @query.group_by,
                      column_names: @query.column_names,
                      totalable_names: @query.totalable_names,
                      sort_criteria: @query.sort_criteria)
  end

  def dashboards_query_cache_key(object_type)
    project_id = @project ? @project.id : 0
    "#{object_type}_query_data_#{session.id}_#{project_id}"
  end

  # Returns the query definition as hidden field tags
  # columns in ignored_column_names are skipped (names as symbols)
  # TODO: this is a temporary fix and should be removed
  # after https://www.redmine.org/issues/29830 is in Redmine core.
  def query_as_hidden_field_tags(query)
    tags = hidden_field_tag 'set_filter', '1', id: nil

    if query.filters.present?
      query.filters.each do |field, filter|
        tags << hidden_field_tag('f[]', field, id: nil)
        tags << hidden_field_tag("op[#{field}]", filter[:operator], id: nil)
        filter[:values].each do |value|
          tags << hidden_field_tag("v[#{field}][]", value, id: nil)
        end
      end
    else
      tags << hidden_field_tag('f[]', '', id: nil)
    end

    ignored_block_columns = query.block_columns.map(&:name)
    query.columns.each do |column|
      next if ignored_block_columns.include? column.name

      tags << hidden_field_tag('c[]', column.name, id: nil)
    end
    if query.totalable_names.present?
      query.totalable_names.each do |name|
        tags << hidden_field_tag('t[]', name, id: nil)
      end
    end
    tags << hidden_field_tag('group_by', query.group_by, id: nil) if query.group_by.present?
    tags << hidden_field_tag('sort', query.sort_criteria.to_param, id: nil) if query.sort_criteria.present?

    tags
  end
end
