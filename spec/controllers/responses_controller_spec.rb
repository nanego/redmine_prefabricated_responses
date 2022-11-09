require "spec_helper"
require "active_support/testing/assertions"

describe ResponsesController, :type => :controller do

  fixtures :responses, :issues, :trackers, :issue_statuses, :enabled_modules,
            :projects, :enumerations, :users, :roles, :members, :member_roles

  render_views

  include ActiveSupport::Testing::Assertions

  describe 'Responses actions' do
    before do
      @request.session[:user_id] = 1
      User.current = User.find(1)
    end

    it "should show All statuses when all statuses are checked" do
      # Response.find(5).initial_status_ids: ['1', '2', '3', '4', '5'], add id 6 to select all statuses
      res_test = Response.find(5)
      res_test.initial_status_ids << "6"
      res_test.save

      get :index

      expect(response).to be_successful
      expect(response.body).to include("All statues") 
    end

	end
end
