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

    it "can be private" do
      expect(response).to have_attributes(is_private: false)
    end

    it "has viisbilty" do
      expect(response).to have_attributes(visibility: 0)
    end

  end

  describe "scope private_for_user" do
    it "should show private and public responses when user(admin)" do
      expect(Response.private_for_user(User.find(1)).count).to eq(2)
    end
    it "should show only private responses when user(not admin)" do
      expect(Response.private_for_user(User.find(2)).count).to eq(1)
    end
  end

  describe "scope global_for_project" do

    it "should show all responses on project when user(admin)" do
      expect(Response.global_for_project(User.find(1), 1).count).to eq(4)
    end

    it "should show only public responses on project when user(not developer)" do
      expect(Response.global_for_project(User.find(2), 1).count).to eq(2)
    end

    it "should show public responses + his private responses + response for developper role on project when user(developper)" do
      member = MemberRole.new(:member_id => 1, :role_id => 2)
      member.save
      expect(Response.global_for_project(User.find(2), 1).count).to eq(3)
    end
  end

end
