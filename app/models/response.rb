# frozen_string_literal: true

class Response < ApplicationRecord
  include Redmine::SafeAttributes

  serialize :initial_status_ids
  serialize :tracker_ids
  serialize :organization_ids

  belongs_to :final_status, class_name: 'IssueStatus'
  belongs_to :author, :class_name => 'User'
  belongs_to :assigned_to, :class_name => 'Principal'
  belongs_to :project
  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :roles, :join_table => "responses_roles", :dependent => :delete_all
  # rubocop:enable Rails/HasAndBelongsToMany

  safe_attributes "name", "initial_status_ids", "final_status_id",
                  "time_limit", "note",
                  "author_id", "project_ids",
                  "enabled", "organization_ids",
                  "tracker_ids", "assigned_to_id",
                  "project_id", "visibility"

  validates_presence_of :name
  validates_presence_of :author, :if => proc { |response| response.new_record? || response.author_id_changed? }

  scope :active, -> { where(enabled: true) }
  # scope :not_private, -> { where(is_private: false) }
  scope :sorted, -> { order(:name) }
  # scope :visible_by, ->(user) { where("is_private = ? OR author_id = ?", false, user.id) }
  before_save :remove_empty_value_from_serialized_field

  VISIBILITY_PRIVATE = 0
  VISIBILITY_ROLES = 1
  VISIBILITY_PUBLIC = 2

  validates :visibility, :inclusion => { :in => [VISIBILITY_PUBLIC, VISIBILITY_ROLES, VISIBILITY_PRIVATE] }

  # User's own responses without project (private or public)
  scope :owned_without_project, ->(user) do
    where(author_id: user.id, project_id: nil)
  end

  # Public responses from other users without project
  scope :public_from_others_without_project, ->(user) do
    where(visibility: VISIBILITY_PUBLIC, project_id: nil).where.not(author_id: user.id)
  end

  def self.global_for_project(user = User.current, project_id)
    scope = joins("INNER JOIN #{Project.table_name} ON #{table_name}.project_id = #{Project.table_name}.id").
      where("#{table_name}.project_id = ?", project_id)
    if user.admin?
      scope
    elsif user.memberships.any?
      scope.where(
        "author_id = ? AND #{table_name}.visibility = ?" +
          " OR #{table_name}.visibility = ?" +
          " OR (#{table_name}.visibility = ? AND #{table_name}.id IN (" +
          "SELECT DISTINCT res.id FROM #{table_name} res" +
          " INNER JOIN responses_roles res_ro on res_ro.response_id = res.id" +
          " INNER JOIN #{MemberRole.table_name} mr ON mr.role_id = res_ro.role_id" +
          " INNER JOIN #{Member.table_name} m ON m.id = mr.member_id AND m.user_id = ?" +
          " INNER JOIN #{Project.table_name} p ON p.id = m.project_id AND m.project_id = ?))",
        user.id, VISIBILITY_PRIVATE, VISIBILITY_PUBLIC, VISIBILITY_ROLES, user.id, project_id)
    else
      none
    end
  end

  def allowed_target_projects
    Project.active
  end

  def self.available_for(user: User.current, status: nil, tracker: nil, project_id: nil)
    # User's own responses without project (always visible to the user)
    own_responses = Response.active.owned_without_project(user)

    # Responses linked to the project (visibility rules apply)
    project_responses = Response.active.global_for_project(user, project_id)

    # Public responses from others without project (only if user has permission)
    public_responses_from_others = []
    if user.allowed_to?(:use_public_responses, Project.find(project_id))
      public_responses_from_others = Response.active.public_from_others_without_project(user)
    end

    responses = own_responses.to_a + project_responses.to_a + public_responses_from_others.to_a
    responses = responses.select { |r| r.initial_status_ids.empty? || r.initial_status_ids.include?(status.id.to_s) } if status.present?
    responses = responses.select { |r| r.tracker_ids.empty? || r.tracker_ids.include?(tracker.id.to_s) } if tracker.present?
    responses.uniq
  end

  def remove_empty_value_from_serialized_field
    organization_ids.delete("") if organization_ids.present? && (organization_ids.include? "")
    initial_status_ids.delete("") if initial_status_ids.present? && (initial_status_ids.include? "")
    tracker_ids.delete("") if tracker_ids.present? && (tracker_ids.include? "")
  end
end
