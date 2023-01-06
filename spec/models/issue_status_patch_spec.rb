require "spec_helper"
require File.dirname(__FILE__) + '/../../lib/redmine_prefabricated_responses/issue_status_patch'

describe "IssueStatusPatch/update reponse table" do

  fixtures :responses, :users, :issue_statuses  

  it "Set final_status_id to nil when deleting a status, delete it from initial_status" do
    response_test = Response.find(5)
    issue_status = IssueStatus.create(:name => "test", :position => 7, :is_closed =>false)
    response_test.final_status_id = issue_status.id
    response_test.initial_status_ids << issue_status.id.to_s
    response_test.save
    
    issue_status.destroy

    expect(Response.find(5).final_status_id).to be_nil
    expect(Response.find(5).initial_status_ids).not_to include(issue_status.id)
  end  

end