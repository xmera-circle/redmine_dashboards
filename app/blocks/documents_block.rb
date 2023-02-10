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

class DocumentsBlock < DashboardBlock
  attr_accessor :max_entries

  validates :max_entries, presence: true, numericality: true, inclusion: { in: (1..100).map(&:to_s) }, allow_nil: true

  def register_type
    'documents'
  end

  def register_label
    -> { l(:label_document_plural) }
  end

  def register_specs
    { permission: :view_documents,
      partial: 'dashboards/blocks/documents' }
  end

  def register_settings
    { max_entries: '' }
  end

  def prepare_custom_locals(settings, dashboard)
    maximum = fetch_max_entries(settings)
    { documents: query_documents(dashboard, maximum),
      max_entries: maximum }
  end

  private

  def fetch_max_entries(settings)
    settings.fetch(:max_entries, default_max_entries)
  end

  def query_documents(dashboard, given_max_entries)
    scope = Document.visible
    scope = scope.where project: dashboard.project if dashboard.project

    scope.order(created_on: :desc)
         .limit(given_max_entries)
         .to_a
  end
end
