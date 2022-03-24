require 'spec_helper'

RSpec.describe Response, :type => :model do

  fixtures :responses, :issues, :trackers, :issue_statuses, :projects, :enumerations

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

  end

end
