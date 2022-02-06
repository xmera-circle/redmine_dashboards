# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2022 Liane Hampe <liaham@xmera.de>, xmera.
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

class DashboardBlockData
  include Redmine::I18n
  include ReportsHelper

  attr_reader :block_id, :project, :field_name, :ordinate

  def initialize(block_id, project, field_name, ordinate)
    @block_id = block_id
    @project = project
    @field_name = field_name.to_s
    @ordinate = ordinate.to_s
  end

  def report_title
    return l(:field_tracker) if ordinate == 'rows'

    l(:field_status)
  end

  ##
  # Labels refer to names of items displayed on the axis of ordinates.
  # It can be either DashboardBlockData#rows or DashboardBlockData#statuses.
  #
  def labels
    send(ordinate).collect(&:name)
  end

  def dataset
    return [] unless project

    send(abscissa).collect { |x_val| { label: x_val.name, hidden: hidden(x_val), data: data(x_val) } }
  end

  def hidden(x_val)
    x_val.is_closed? if ordinate == 'rows'
  end

  def statuses
    project.rolled_up_statuses.sorted.to_a
  end

  def abscissa
    %w[rows statuses].reject { |dimension| dimension == ordinate }.first
  end

  def detail
    case ordinate
    when 'rows'
      'tracker'
    else
      'status'
    end
  end

  ##
  # @return [Array(Hash)] An array of hashes with sums of tracker having a
  #   certain status.
  #
  # @example
  # [{"status_id"=>"1", "closed"=>false, "tracker_id"=>"1", "total"=>"1"},
  #  {"status_id"=>"1", "closed"=>false, "tracker_id"=>"2", "total"=>"3"},
  #  {"status_id"=>"2", "closed"=>false, "tracker_id"=>"3", "total"=>"1"},
  #  {"status_id"=>"2", "closed"=>false, "tracker_id"=>"8", "total"=>"1"}]
  #
  def query
    Issue.by_tracker(project, with_subprojects).map(&:with_indifferent_access)
  end

  ##
  # @return [Array(Tracker)] A list of Tracker objects of a set of projects
  #   which are visible to the user.
  #
  def rows
    project.rolled_up_trackers(with_subprojects).visible
  end

  private

  def data(x_val)
    send(ordinate).collect { |y_val| aggregate(query, criteria(x_val, y_val)) }
  end

  def criteria(x_val, y_val)
    x_val_id = x_val.id
    y_val_id = y_val.id
    return { "#{field_name}": y_val_id, status_id: x_val_id } if y_val.is_a?(Tracker)

    { "#{field_name}": x_val_id, status_id: y_val_id }
  end

  def with_subprojects
    Setting.display_subprojects_issues?
  end
end
