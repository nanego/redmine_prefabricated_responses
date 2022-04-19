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
      expect(issue_7.available_responses.size).to eq 3
    end

    it "does not return responses if current status does not match configured status in rules" do
      issue_7.update(status_id: 5) # Close issue
      expect(issue_7.available_responses).to be_empty
    end

    it "returns responses if current status matches configured status in rules" do
      issue_7.update(status_id: 5) # Close issue
      response.update(initial_status_ids: ['1', '2', '5'])
      expect(issue_7.available_responses).to include response
    end

    it "returns an array of responses when(initial_status_ids are empty or contains status new) (tracker_ids are empty or contains bug) " do
      User.current = User.find(1)
      res = Response.find(6)

      expect(issue_7.available_responses.size).to eq 5
      expect(issue_7.available_responses).to_not include(res)

      res.initial_status_ids << "1"
      res.save

      expect(issue_7.available_responses.size).to eq 6
      expect(issue_7.available_responses).to include(res)
    end
  end

  context "add responses" do
    it "adds a response to a specific issue" do
      issue_7.add_response(response_without_final_status, User.find(1))
      expect(Journal.last.notes).to eq(Response.find(2).note)
    end

    it "can add a response without changing the status" do
      issue_7.add_response(response_without_final_status, User.find(1))
      expect(issue_7.status.id).to eq(1)
    end

    it "can add a response without final status" do
      issue_7.add_response(response, User.find(1))
      expect(issue_7.status.id).to eq(response.final_status_id)
    end
  end

  context "test permission for a public response of admin" do
    it "should not be included when the user does not have the permission(use_public_responses)" do
      expect(Issue.find(1).available_responses(User.find(2)).count).to eq(3)
    end

    it "should be included only when the user has the permission(use_public_responses)" do
      project = Project.find(1)
      user = User.find(2)
      project.enabled_module_names = ['issue_tracking', 'prefabricated_responses']
      role = User.find(2).roles_for_project(project).first
      role.add_permission! :use_public_responses
      expect(Issue.find(1).available_responses(user).count).to eq(4)
    end
  end
end
