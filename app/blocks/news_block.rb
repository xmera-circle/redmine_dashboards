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

class NewsBlock < DashboardBlock
  attr_accessor :max_entries

  validates :max_entries, presence: true, numericality: true, inclusion: { in: (1..100).map(&:to_s) }, allow_nil: true

  def register_type
    'news'
  end

  def register_label
    -> { l(:label_news_latest) }
  end

  def register_specs
    { permission: :view_news,
      partial: 'dashboards/blocks/news' }
  end

  def register_settings
    { max_entries: nil }
  end

  def prepare_custom_locals(settings, dashboard)
    maximum = fetch_max_entries(settings)
    { max_entries: maximum,
      news: query_news(dashboard, maximum) }
  end

  private

  def fetch_max_entries(settings)
    settings.fetch(:max_entries, default_max_entries)
  end

  def query_news(dashboard, given_max_entries)
    return latest_news(given_max_entries) if dashboard.content_project.nil?

    dashboard
      .content_project
      .news
      .limit(given_max_entries)
      .includes(:user, :project)
      .reorder(created_on: :desc)
      .to_a
  end

  def latest_news(given_max_entries)
    News.latest User.current, given_max_entries
  end
end
