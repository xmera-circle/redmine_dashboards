# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2020 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
# See <https://github.com/AlphaNodes/additionals>.
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

class CreateDashboardRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :dashboard_roles do |t|
      t.references :dashboard,
                   null: false,
                   foreign_key: { on_delete: :cascade }
      t.references :role,
                   null: false,
                   type: :integer,
                   foreign_key: { on_delete: :cascade }
      t.index %i[dashboard_id role_id], name: 'dashboard_role_ids', unique: true
    end
  end
end
