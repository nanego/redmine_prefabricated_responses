class Response < ActiveRecord::Base

  include Redmine::SafeAttributes

  serialize :initial_status_ids
  serialize :tracker_ids
  serialize :organization_ids

  belongs_to :final_status, class_name: 'IssueStatus'

  safe_attributes "name", "initial_status_ids", "final_status_id",
                  "time_limit", "note",
                  "author_id", "project_ids",
                  "enabled", "organization_ids",
                  "tracker_ids"

  validates_presence_of :name

  scope :active, -> { where(enabled: true) }

  def allowed_target_projects
    Project.active
  end

end
