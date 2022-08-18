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
  validates :max_entries, presence: true, numericality: true, inclusion: { in: (1..100).map(&:to_s) }, allow_nil: true

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

  def dashboard_feed_title(title)
    title.presence || label
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

  private

  def valid_url
    parsed = URI.parse(url)
    check = parsed.is_a?(URI::HTTP) || parsed.is_a?(URI::HTTPS)
    errors.add(:base, :invalid) unless check
  rescue StandardError => e
    logger.error e.full_message
  end
end
