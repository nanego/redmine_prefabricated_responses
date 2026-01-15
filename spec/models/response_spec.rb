require 'spec_helper'

RSpec.describe Response, :type => :model do

  fixtures :responses, :issues, :trackers, :issue_statuses, :projects, :enumerations, :responses_roles

  let!(:response) { Response.find(1) }
  let!(:response_without_final_status) { Response.find(2) }
  let!(:issue_7) { Issue.find(7) }

  context "attributes" do

    it "has initial_status_ids" do
      expect(response).to have_attributes(initial_status_ids: ['1', '2'])
    end

    it "has final_status_id" do
      expect(response).to have_attributes(final_status_id: 5)
      expect(response.final_status).to eq IssueStatus.find(5)
    end

    it "has note" do
      expect(response).to have_attributes(note: "I'm closing this issue")
    end

    it "has tracker_ids" do
      expect(response).to have_attributes(tracker_ids: ["1", "2"])
    end

    it "has an author" do
      expect(response).to have_attributes(author: User.find(2))
    end

    it "has viisbilty" do
      expect(response).to have_attributes(visibility: 0)
    end

  end

  describe "scope owned_without_project" do
    it "shows all responses owned by user without project" do
      # User 1 (admin) owns responses 4 (public) and 5 (private) without project
      expect(Response.owned_without_project(User.find(1)).count).to eq(2)
    end
    it "shows all responses owned by non-admin user without project" do
      # User 2 owns responses 1 (private) and 8 (public) without project
      expect(Response.owned_without_project(User.find(2)).count).to eq(2)
    end
  end

  describe "scope public_from_others_without_project" do
    it "shows public responses from others for admin" do
      # Response 8 is public from user 2
      expect(Response.public_from_others_without_project(User.find(1)).count).to eq(1)
    end
    it "shows public responses from others for non-admin" do
      # Response 4 is public from user 1
      expect(Response.public_from_others_without_project(User.find(2)).count).to eq(1)
    end
  end

  describe "scope global_for_project" do
    it "shows all responses on project when user is admin" do
      expect(Response.global_for_project(User.find(1), 1).count).to eq(4)
    end

    it "shows only public responses on project when user has not the developer role" do
      expect(Response.global_for_project(User.find(2), 1).count).to eq(2)
    end

    it "shows public responses + his private responses + response for developer role on project when user has developer role" do
      member = MemberRole.new(:member_id => 1, :role_id => 2)
      member.save
      expect(Response.global_for_project(User.find(2), 1).count).to eq(3)
    end
  end

end
