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

class FeedBlock < DashboardBlock
  attr_accessor :title, :text, :url, :max_entries

  validate :valid_url
  validates :url, presence: true
  validates :max_entries, presence: true, numericality: true, inclusion: { in: (1..100).map(&:to_s) }

  def register_type
    'feed'
  end

  def register_label
    -> { l(:label_feed) }
  end

  def register_specs
    { max_frequency: MAX_MULTIPLE_OCCURS,
      async: { required_settings: %i[url],
               cache_expires_in: 600,
               skip_user_id: true,
               partial: 'dashboards/blocks/feed' } }
  end

  def register_settings
    { title: nil,
      url: nil,
      max_entries: nil }
  end

  def valid_url
    parsed = URI.parse(url)
    check = parsed.is_a?(URI::HTTP) || parsed.is_a?(URI::HTTPS)
    errors.add(:base, :invalid) unless check
  rescue StandardError => e
    logger.error e.full_message
  end
end
