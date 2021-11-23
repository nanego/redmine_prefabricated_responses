module RedminePrefabricatedResponses
  module IssuePatch

    def add_response(response, user = User.current)
      init_journal(user, response.note)
      self.status = response.final_status if response.final_status.present?
      save
    end

    def available_responses(user = User.current)
      return [] unless user.allowed_to?(:edit_issues, project) || (user.allowed_to?(:edit_own_issues, project) && user == author)
      responses = Response.available_for(user: user, status: self.status)
      # TODO Filter available responses for current issue and current user
      responses
    end

  end
end
