require "spec_helper"
require "active_support/testing/assertions"

RSpec.describe "IssueController", type: :system do
  include ActiveSupport::Testing::Assertions
  include IssuesHelper

  fixtures :projects,
           :users, :email_addresses, :user_preferences,
           :roles,
           :members,
           :member_roles,
           :issues,
           :responses,
           :issue_statuses,
           :trackers,
           :issue_relations,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :responses,
           :workflows

  describe "prefabricated responses" do

    before do
      log_user('jsmith', 'jsmith')
    end

    it "Modifies assigned to when selecting a prefabricated response" do
      response = Response.find(2)
      response.final_status_id = 3
      response.assigned_to_id = 2
      response.save

      visit "/issues/1/edit"

      find("#select-response-tag option[value='2']").select_option
      find("a#apply-response-submit").click

      expect(page.find('#issue_assigned_to_id').value).to eq('2')

      find("input[type='submit']").click

      issue = Issue.find(1)
      expect(issue.assigned_to_id).to eq(2)
    end

    it "Modifies status to when selecting a prefabricated response" do
      response = Response.find(2)
      response.final_status_id = 3
      response.assigned_to_id = 2
      response.save

      visit "/issues/1/edit"

      find("#select-response-tag option[value='2']").select_option
      find("a#apply-response-submit").click

      expect(page.find('#issue_status_id').value).to eq('3')
      find("input[type='submit']").click

      issue = Issue.find(1)
      expect(issue.status_id).to eq(3)
    end

  end
end