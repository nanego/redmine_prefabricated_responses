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

  describe 'Sidebar link to responses' do
    before do
      @request.session[:user_id] = 2
      Role.find(1).remove_permission!(:manage_own_responses, :manage_public_responses)
    end

    it "hides the link when the user cannot manage any response" do
      get :index

      expect(response).to be_successful
      assert_select "#sidebar a[href='/responses']", 0
    end

    it "shows the link when the user can manage their own responses in a project" do
      Role.find(1).add_permission! :manage_own_responses
      get :index

      expect(response).to be_successful
      assert_select "#sidebar a[href='/responses']", 1
    end

    it "shows the link when the user can manage public responses in a project" do
      Role.find(1).add_permission! :manage_public_responses
      get :index, params: { project_id: 'onlinestore' }

      expect(response).to be_successful
      assert_select "#sidebar a[href='/responses']", 1
    end
  end
end