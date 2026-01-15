# frozen_string_literal: true

module RedminePrefabricatedResponses
  module IssuePatch
    def add_response(response, user = User.current)
      init_journal(user, response.note)
      self.status = response.final_status if response.final_status.present?
      self.assigned_to = User.current if response.assigned_to_id.present? && response.assigned_to_id == 0
      self.assigned_to = response.assigned_to if response.assigned_to.present?
      save
    end

    def available_responses(user = User.current)
      return [] unless user.allowed_to?(:edit_issues, project) || (user.allowed_to?(:edit_own_issues, project) && user == author)

      Response.available_for(user: user, status: status, tracker: tracker, project_id: project.id)
    end
  end
end

Issue.prepend RedminePrefabricatedResponses::IssuePatch
