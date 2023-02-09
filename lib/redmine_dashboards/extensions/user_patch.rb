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

module RedmineDashboards
  module Extensions
    module UserPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          has_many :dashboards, dependent: :nullify
        end
      end

      module ClassMethods
        # NOTE: this is a better (performance related) solution as:
        # authors = users.to_a.select { |u| u.allowed_to? permission, project, global: project.nil? }
        def with_permission(permission, project = nil)
          # Clear cache for debuging performance issue
          # ActiveRecord::Base.connection.clear_query_cache

          role_ids = Role.builtin(false).select { |p| p.permissions.include? permission }
          role_ids.map!(&:id)

          admin_ids = User.visible.active.where(admin: true).ids

          member_scope = Member.joins(:member_roles, :project)
                               .where(projects: { status: Project::STATUS_ACTIVE },
                                      user_id: User.all,
                                      member_roles: { role_id: role_ids })
                               .select(:user_id)
                               .distinct

          if project.nil?
            # user_ids = member_scope.pluck(:user_id) | admin_ids
            # where(id: user_ids)
            where(id: member_scope).or(where(id: admin_ids))
          else
            # user_ids = member_scope.where(project_id: project).pluck(:user_id)
            # where(id: user_ids).or(where(id: admin_ids))
            where(id: member_scope.where(project_id: project)).or(where(id: admin_ids))
          end
        end
      end
    end
  end
end
