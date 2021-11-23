class Response < ActiveRecord::Base

  include Redmine::SafeAttributes

  serialize :initial_status_ids
  serialize :tracker_ids
  serialize :organization_ids

  belongs_to :final_status, class_name: 'IssueStatus'
  belongs_to :author, :class_name => 'User'

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

  def allowed_target_projects
    Project.active
  end

  def self.available_for(user: User.current, status: nil)
    responses = Response.active.visible_by(user)
    responses = responses.select { |r| r.initial_status_ids.include?(status.id.to_s) } if status.present?
    responses
  end

  # Returns true if usr or current user is allowed to view the response
  def visible?(usr = nil)
    (usr || User.current).allowed_to?(:view_prefabricated_responses, self.project) do |role, user|
      user.admin? || !self.is_private? || self.author == user
    end
  end

end
