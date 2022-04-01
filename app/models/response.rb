class Response < ActiveRecord::Base

  include Redmine::SafeAttributes

  serialize :initial_status_ids
  serialize :tracker_ids
  serialize :organization_ids

  belongs_to :final_status, class_name: 'IssueStatus'
  belongs_to :author, :class_name => 'User'
  belongs_to :project
  has_and_belongs_to_many :roles, :foreign_key => "response_id", :join_table => "responses_roles", :dependent => :delete_all

  safe_attributes "name", "initial_status_ids", "final_status_id",
                  "time_limit", "note",
                  "author_id", "project_ids",
                  "enabled", "organization_ids",
                  "tracker_ids", "is_private",
                  "project_id", "visibility"

  validates_presence_of :name
  validates_presence_of :author, :if => Proc.new { |response| response.new_record? || response.author_id_changed? }

  scope :active, -> { where(enabled: true) }
  scope :not_private, -> { where(is_private: false) }
  scope :sorted, -> { order(:name) }
  scope :visible_by, ->(user) { where("is_private = ? OR author_id = ?", false, user.id) }
  before_save :remove_empty_value_from_serialized_field

  VISIBILITY_PRIVATE = 0
  VISIBILITY_ROLES   = 1
  VISIBILITY_PUBLIC  = 2

  validates :visibility, :inclusion => {:in => [VISIBILITY_PUBLIC, VISIBILITY_ROLES, VISIBILITY_PRIVATE]}
  scope :private_for_user, ->(user) do
    if user.admin?
      where("visibility <> ? And author_id = ? AND project_id IS NULL", VISIBILITY_ROLES, user.id)
    else
      where("visibility = ? And author_id = ? AND project_id IS NULL", VISIBILITY_PRIVATE, user.id)
    end
  end

  def self.global_for_project(user = User.current, project_id)
    scope = joins("INNER JOIN #{Project.table_name} ON #{table_name}.project_id = #{Project.table_name}.id").
      where("#{table_name}.project_id = ?", project_id)
    if user.admin?
      #scope.where("#{table_name}.visibility <> ?", VISIBILITY_PRIVATE)
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
    end
  end

  def allowed_target_projects
    Project.active
  end

  def self.available_for(user: User.current, status: nil, tracker: nil, project_id: nil)
    private_responses = Response.active.private_for_user(user)
    global_responses = Response.active.global_for_project(user, project_id)
    responses = private_responses.to_a + global_responses.to_a
    responses = responses.select { |r| r.initial_status_ids.include?(status.id.to_s) } if status.present?
    responses = responses.select { |r| r.tracker_ids.include?(tracker.id.to_s) } if tracker.present?
    responses.uniq
  end

  # Returns true if usr or current user is allowed to view the response
  def visible?(usr = nil)
    (usr || User.current).allowed_to?(:view_prefabricated_responses, self.project) do |role, user|
      user.admin? || !self.is_private? || self.author == user
    end
  end

  def remove_empty_value_from_serialized_field
    organization_ids.delete("") if organization_ids.present? && (organization_ids.include? "")
    initial_status_ids.delete("") if initial_status_ids.present? && (initial_status_ids.include? "")
    tracker_ids.delete("") if tracker_ids.present? && (tracker_ids.include? "")
  end
end
