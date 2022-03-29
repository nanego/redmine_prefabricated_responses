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
                  "tracker_ids", "is_private"

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

  def allowed_target_projects
    Project.active
  end

  def self.available_for(user: User.current, status: nil, tracker: nil)
    responses = Response.active.visible_by(user)
    responses = responses.select { |r| r.initial_status_ids.include?(status.id.to_s) } if status.present?
    responses = responses.select { |r| r.tracker_ids.include?(tracker.id.to_s) } if tracker.present?
    responses
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
