# frozen_string_literal: true

# This file is part of the Plugin Redmine Dashboards.
#
# Copyright (C) 2020 - 2021 Alexander Meindl <https://github.com/alexandermeindl>, alphanodes.
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

class Dashboard < ActiveRecord::Base
  include Redmine::I18n
  include Redmine::SafeAttributes

  class SystemDefaultChangeException < StandardError; end
  class ProjectSystemDefaultChangeException < StandardError; end

  belongs_to :project
  belongs_to :author, class_name: 'User'
  has_many :dashboard_roles, dependent: :destroy
  has_many :roles, through: :dashboard_roles

  # current active project (belongs_to :project can be nil, because this is system default)
  attr_accessor :content_project

  serialize :options

  VISIBILITY_PRIVATE = 0
  VISIBILITY_ROLES   = 1
  VISIBILITY_PUBLIC  = 2

  delegate :groups, to: :content, prefix: :available
  delegate :find_block, to: :block_klass

  scope :by_project, (->(project_id) { where project_id: project_id if project_id.present? })
  scope :sorted, (-> { order "#{Dashboard.table_name}.name" })
  scope :welcome_only, (-> { where dashboard_type: DashboardContentWelcome::TYPE_NAME })

  safe_attributes 'name', 'description', 'enable_sidebar',
                  'always_expose', 'project_id', 'author_id',
                  if: (lambda do |dashboard, user|
                    dashboard.new_record? ||
                      dashboard.editable?(user)
                  end)

  safe_attributes 'dashboard_type',
                  if: ->(dashboard, _user) { dashboard.new_record? }

  safe_attributes 'visibility', 'role_ids',
                  if: ->(dashboard, user) { dashboard.editable? user }

  safe_attributes 'system_default',
                  if: (lambda do |dashboard, user|
                    dashboard.allowed_to_manage_system_dashboards?(user, dashboard.project)
                  end)

  before_validation :strip_whitespace

  before_save :dashboard_type_check, :visibility_check, :set_options_hash, :clear_unused_block_settings

  before_destroy :check_destroy_system_default
  after_save :update_system_defaults
  after_save :remove_unused_role_relations

  validates :name, :dashboard_type, :author, :visibility, presence: true
  validates :visibility, inclusion: { in: [VISIBILITY_PUBLIC, VISIBILITY_ROLES, VISIBILITY_PRIVATE] }
  validate :validate_roles
  validate :validate_visibility
  validate :validate_name
  validate :validate_system_default
  validate :validate_project_system_default
  validate :validate_layout_settings

  class << self
    def default(dashboard_type, project = nil, user = User.current)
      recently_id = User.current.pref.recently_used_dashboard dashboard_type, project

      scope = where dashboard_type: dashboard_type
      scope = scope.where(project_id: project.id).or(scope.where(project_id: nil)) if project.present?

      selected = scope.visible
      dashboard = selected.select { |item| item.id == recently_id }

      return dashboard.first if dashboard.present?

      remove_invalid_recently_id(recently_id, dashboard_type)
      system_default(dashboard_type)
    end

    def system_default(dashboard_type)
      find_by(dashboard_type: dashboard_type, system_default: true)
    end

    def remove_invalid_recently_id(recently_id, dashboard_type)
      return unless recently_id

      Rails.logger.debug 'default cleanup required'
      User.current.pref.recently_used_dashboards[dashboard_type] = nil
    end

    def fields_for_order_statement(table = nil)
      table ||= table_name
      ["#{table}.name"]
    end

    ##
    # A user is allowed to see a dashboard if
    #  i) she is allowed to edit it,
    #  ii) she is authorized by her role, having in any project, to read it,
    #  iii) it is public or her own dashboard.
    #
    def visible(user = User.current, **options)
      return all if all.all? { |item| item.editable?(user) || item.system_default? }

      scoped = left_outer_joins :project
      scoped = scoped.where(projects: { id: nil }).or(scoped.where(Project.allowed_to_condition(user, :view_project,
                                                                                                options)))
      if user.memberships.any?
        scoped.where("#{table_name}.visibility = ?" \
                    " OR (#{table_name}.visibility = ? AND #{table_name}.id IN (" \
                    "SELECT DISTINCT d.id FROM #{table_name} d"  \
                    " INNER JOIN #{table_name_prefix}dashboard_roles#{table_name_suffix} dr ON dr.dashboard_id = d.id" \
                    " INNER JOIN #{MemberRole.table_name} mr ON mr.role_id = dr.role_id" \
                    " INNER JOIN #{Member.table_name} m ON m.id = mr.member_id AND m.user_id = ?" \
                    " INNER JOIN #{Project.table_name} p ON p.id = m.project_id AND p.status <> ?" \
                    ' WHERE d.project_id IS NULL OR d.project_id = m.project_id))' \
                    " OR #{table_name}.author_id = ?",
                    VISIBILITY_PUBLIC,
                    VISIBILITY_ROLES,
                    user.id,
                    Project::STATUS_ARCHIVED,
                    user.id)
      elsif user.logged?
        scoped.where(visibility: VISIBILITY_PUBLIC).or(scoped.where(author_id: user.id))
      else
        scoped.where visibility: VISIBILITY_PUBLIC
      end
    end
  end

  def initialize(attributes = nil, *args)
    super
    set_options_hash
  end

  def block_klass
    DashboardBlock
  end

  def set_options_hash
    self.options ||= {}
  end

  def [](attr_name)
    if has_attribute? attr_name
      super
    else
      options ? options[attr_name] : nil
    end
  end

  def []=(attr_name, value)
    if has_attribute? attr_name
      super
    else
      attrs = (self[:options] || {}).dup
      attrs.update attr_name => value
      self[:options] = attrs
      value
    end
  end

  ##
  # A user is allowed to see a dashboard if
  #  i) she is allowed to edit it,
  #  ii) it is public,
  #  iii) she is authorized by her role, having in any project, to read it.
  #
  def visible?(user = User.current)
    return true if editable? user

    case visibility
    when VISIBILITY_PUBLIC
      true
    when VISIBILITY_ROLES
      any_authorized?(user) || author?(user)
    end
  end

  def content
    @content ||=
      "DashboardContent#{dashboard_type[0..-10]}".constantize.new(
        project: content_project.presence || project, block_klass: block_klass
      )
  end

  def available_groups
    content.groups
  end

  def layout
    self[:layout] ||= content.default_layout.deep_dup
  end

  def layout=(arg)
    self[:layout] = arg
  end

  def layout_settings(block_id = nil)
    settings = self[:layout_settings] ||= {}
    return settings unless block_id

    settings[block_id] ||= {}
  end

  def layout_settings=(arg)
    self[:layout_settings] = arg
  end

  def remove_block(block_id)
    block_id = block_id.to_s.underscore
    layout.each_key do |group|
      layout[group].delete block_id
    end
    layout
  end

  # Adds block to the user page layout
  # Returns nil if block is not valid or if it's already
  # present in the user page layout
  def add_block(block_id)
    block_id = block_id.to_s.underscore
    return unless content.valid_block? block_id, layout.values.flatten

    remove_block block_id
    # add it to the first group
    group = available_groups.first
    layout[group] ||= []
    layout[group].unshift block_id
  end

  # Sets the block order for the given group.
  # Example:
  #   preferences.order_blocks('left', ['issueswatched', 'news'])
  def order_blocks(group, block_ids)
    group = group.to_s
    return if content.groups.exclude?(group) || block_ids.blank?

    block_ids = block_ids.map(&:underscore) & layout.values.flatten
    block_ids.each { |block_id| remove_block block_id }
    layout[group] = block_ids
  end

  def update_block_settings(block_id, settings)
    block_id = block_id.to_s
    block_settings = layout_settings(block_id).merge(settings.symbolize_keys)
    layout_settings[block_id] = block_settings
  end

  def private?(user = User.current)
    author?(user) && visibility == VISIBILITY_PRIVATE
  end

  def author?(user = User.current)
    author_id == user.id
  end

  def public?
    visibility != VISIBILITY_PRIVATE
  end

  def editable?(usr = User.current)
    @editable ||= editable_by? usr
  end

  def editable_by?(user = User.current, prj = nil)
    prj ||= project
    return true if user&.admin?

    if system_default?
      allowed_to_manage_system_dashboards?(user, prj)
    else
      allowed_to_edit_dashboards?(user, prj)
    end
  end

  def destroyable?
    @destroyable ||= destroyable_by?
  end

  def destroyable_by?(usr = User.current)
    return false if system_default? || !editable_by?(usr, project)

    true
  end

  def to_s
    name
  end

  # Returns a string of css classes that apply to the entry
  def css_classes(user = User.current)
    s = ['dashboard']
    s << 'created-by-me' if author_id == user.id
    s.join ' '
  end

  def allowed_target_projects(user = User.current)
    Project.where Project.allowed_to_condition(user, :add_dashboards)
  end

  # this is used to get unique cache for blocks
  def async_params(block_id, options, settings)
    if block_id.blank?
      msg = 'block is missing for dashboard_async'
      Rails.log.error msg
      raise msg
    end

    config = { dashboard_id: id,
               block_id: block_id }

    if RedmineDashboards.false? options[:skip_user_id]
      settings[:user_id] = User.current.id
      settings[:user_is_admin] = User.current.admin?
    end

    if settings.present?
      settings.each do |key, setting|
        settings[key] = setting.reject(&:blank?).join(',') if setting.is_a? Array

        next if options[:exposed_params].blank?

        options[:exposed_params].each do |exposed_param|
          if key == exposed_param
            config[key] = settings[key]
            settings.delete key
          end
        end
      end

      unique_params = settings.flatten
      unique_params += options[:unique_params].reject(&:blank?) if options[:unique_params].present?

      # Rails.logger.debug "debug async_params for #{block}: unique_params=#{unique_params.inspect}"
      # For truncating hash security, see https://crypto.stackexchange.com/questions/9435/is-truncating-a-sha512-hash-to-the-first-160-bits-as-secure-as-using-sha1
      # truncating should solve problem with long filenames on some file systems
      config[:unique_key] = Digest::SHA256.hexdigest(unique_params.join('_'))[0..-20]
    end

    # Rails.logger.debug "debug async_params for #{block}: config=#{config.inspect}"

    config
  end

  def project_id_can_change?
    return true if new_record? ||
                   dashboard_type == DashboardContentWelcome::TYPE_NAME ||
                   !system_default_was ||
                   project_id_was.present?
  end

  def allowed_to_manage_system_dashboards?(user, prj = nil)
    user.allowed_to?(:manage_system_dashboards, prj, global: true)
  end

  private

  def any_authorized?(user)
    user.memberships.joins(:member_roles).where(member_roles: { role_id: role_ids }).any?
  end

  def allowed_to_edit_dashboards?(user, prj = nil)
    allowed_to_edit_public_dashboards?(user, prj) ||
      allowed_to_edit_own_dashboards?(user, prj)
  end

  def allowed_to_edit_public_dashboards?(user, prj = nil)
    user.allowed_to?(:edit_public_dashboards, prj, global: true)
  end

  def allowed_to_edit_own_dashboards?(user, prj = nil)
    (author == user && user.allowed_to?(:edit_own_dashboards, prj, global: true))
  end

  def strip_whitespace
    name&.strip!
  end

  def clear_unused_block_settings
    block_ids = layout.values.flatten
    layout_settings.keep_if { |block_id, _settings| block_ids.include? block_id }
  end

  def remove_unused_role_relations
    return if !saved_change_to_visibility? || visibility == VISIBILITY_ROLES

    roles.clear
  end

  def validate_roles
    return if visibility != VISIBILITY_ROLES || roles.present?

    errors.add(:base,
               [l(:label_role_plural), l('activerecord.errors.messages.blank')].join(' '))
  end

  def validate_system_default
    return if new_record? ||
              system_default_was == system_default ||
              system_default? ||
              project_id.present?

    raise SystemDefaultChangeException
  end

  def validate_project_system_default
    return if project_id_can_change?

    raise ProjectSystemDefaultChangeException if project_id.present?
  end

  def check_destroy_system_default
    raise 'It is not allowed to delete dashboard, which is system default' unless destroyable?
  end

  def dashboard_type_check
    self.project_id = nil if dashboard_type == DashboardContentWelcome::TYPE_NAME
  end

  def update_system_defaults
    return unless system_default? && User.current.allowed_to?(:manage_system_dashboards, project, global: true)

    scope = self.class
                .where(dashboard_type: dashboard_type)
                .where.not(id: id)

    scope.update_all system_default: false
  end

  # check if permissions changed and dashboard settings have to be corrected
  def visibility_check
    user = User.current

    return if system_default? ||
              allowed_to_edit_dashboards?(user, project) ||
              allowed_to_manage_system_dashboards?(user, project)

    # change to private
    self.visibility = VISIBILITY_PRIVATE
  end

  def validate_visibility
    return unless system_default? && visibility != VISIBILITY_PUBLIC

    errors.add :base, l(:error_dashboard_must_be_visible_for_everyone)
  end

  def validate_name
    return if name.blank?

    scope = self.class.visible.where name: name
    scope = scope.welcome_only

    scope = scope.where.not id: id unless new_record?
    errors.add :name, :name_not_unique if scope.count.positive?
  end

  def validate_layout_settings
    return if layout_settings.empty?

    block_ids = layout_settings&.keys
    block_ids.each do |block_id|
      block = find_block(block_id)
      block.validate_settings(layout_settings[block_id], self)
    end
  end
end
