require_dependency 'project'

module RedminePrefabricatedResponses
  module ProjectPatch

  end
end

class Project < ActiveRecord::Base
  has_many :responses, :dependent => :destroy
  prepend RedminePrefabricatedResponses::ProjectPatch
end
