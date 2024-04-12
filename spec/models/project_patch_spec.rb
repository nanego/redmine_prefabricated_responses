require "spec_helper"
require File.dirname(__FILE__) + '/../../lib/redmine_prefabricated_responses/project_patch'

describe "ProjectPatch/update reponse table" do

  fixtures :responses, :projects

  it "Delete, a project should delete its responses" do
    project_test = Project.create!(:name => "test", :identifier => "test")
    Response.find(5).update(project_id: project_test.id)

    expect do
      project_test.destroy
    end.to change { Response.count }.by(-1)

  end

end
