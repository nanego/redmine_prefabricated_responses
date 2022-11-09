require "spec_helper"
require "active_support/testing/assertions"

describe IssuesController, :type => :controller do

  fixtures :responses, :issues, :trackers, :issue_statuses, :enabled_modules,
            :projects, :enumerations, :users, :roles, :members, :member_roles

  render_views

  include ActiveSupport::Testing::Assertions

  describe 'Responses actions' do
    before do
      @request.session[:user_id] = 1
      User.current = User.find(1)
    end 

    it "should should be pre-select the option ,if there is only one option" do
      res_test = Response.find(2)
      res_test.enabled = false  
      res_test.save
      res_test = Response.find(7)
      res_test.enabled = false  
      res_test.save
      get :show, :params => { :id => 1 }

      expect(response).to be_successful

      assert_select 'select#response_id', :text => /Private response of admin/
    end

	end
end
