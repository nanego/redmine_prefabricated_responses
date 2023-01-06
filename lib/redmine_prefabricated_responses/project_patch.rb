require_dependency 'project'

class Project < ActiveRecord::Base

  has_many :responses, :dependent => :destroy
  
end
