# frozen_string_literal: true

require_dependency 'project'

module RedminePrefabricatedResponses
  module ProjectPatch
  end
end

class Project
  has_many :responses, :dependent => :destroy
  prepend RedminePrefabricatedResponses::ProjectPatch
end
