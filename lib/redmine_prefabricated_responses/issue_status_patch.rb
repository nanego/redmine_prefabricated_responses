require_dependency 'issue_status'

module RedminePrefabricatedResponses
  module IssueStatusPatch
    def remove_references_before_destroy
      responses = Response.all
      responses = responses.select { |r| r.initial_status_ids.include?(id.to_s) }
      responses.each do |response|
        response.initial_status_ids.delete(id.to_s)
        response.save
      end
    end
  end
end

class IssueStatus

  has_many :responses, :foreign_key => "final_status_id", dependent: :nullify
  before_destroy :remove_references_before_destroy

  prepend RedminePrefabricatedResponses::IssueStatusPatch
end
