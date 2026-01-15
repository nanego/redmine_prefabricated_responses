# frozen_string_literal: true

require_dependency 'tracker'

module RedminePrefabricatedResponses
  module TrackerPatch
    def remove_references_before_destroy
      responses = Response.all
      responses = responses.select { |r| r.tracker_ids.include?(id.to_s) }
      responses.each do |response|
        response.tracker_ids.delete(id.to_s)
        response.save
      end
    end
  end
end

class Tracker
  before_destroy :remove_references_before_destroy
  prepend RedminePrefabricatedResponses::TrackerPatch
end
