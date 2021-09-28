require 'spec_helper'

RSpec.describe Issue, :type => :model do

  fixtures :responses, :issues, :trackers, :issue_statuses, :enabled_modules,
           :projects, :enumerations, :users, :roles, :members, :member_roles

  let!(:response) { Response.find(1) }
  let!(:response_without_final_status) { Response.find(2) }
  let!(:issue_7) { Issue.find(7) }

  before do
    User.current = User.find(2)
  end

  context "issue available responses" do
    it "returns an empty array if user cannot update the issue" do
      User.current = User.anonymous
      expect(issue_7.available_responses).to be_empty
    end

    it "returns an array of responses" do
      expect(issue_7.available_responses.size).to eq 2
    end

  end

  context "add responses" do
    pending "adds a response to a specific issue"
    pending "can add a response without changing the status"
    pending "can add a response without final status"
  end

end
