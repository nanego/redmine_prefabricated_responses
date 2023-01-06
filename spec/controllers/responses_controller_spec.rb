require 'spec_helper'

describe ResponsesController, type: :controller do
  render_views

  fixtures :users, :issues, :issue_statuses, :responses, :responses_roles, :trackers, :projects, :enumerations,
           :journals, :roles, :members, :member_roles, :issue_categories

  include Redmine::I18n

  let!(:project_1) { Project.find(1) }
  let!(:user_2) { User.find(2) }

  before do
    @controller = ResponsesController.new
    @request = ActionDispatch::TestRequest.create
    @response = ActionDispatch::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # permissions admin
    Project.find(1).enabled_module_names = ['issue_tracking', 'prefabricated_responses']
  end

  describe "POST create" do
    it "creates a response for this project and redirects to project_responses_path " do
      expect do
        post :create, :params => {
          :response => {
            name: 'new_response',
            enabled: '1',
            project_id: '1',
            visibility: '2',
            initial_status_ids: ['1'],
            final_status_id: '5',
            tracker_ids: ['1'],
            note: 'note for test'
          }
        }
      end.to change { Response.count }.by(1)
      response = Response.last

      expect(response).to redirect_to('/projects/1/responses')
      expect(response.name).to eq('new_response')
      expect(response.project).to eq(project_1)
    end

    it "creates a response without project and redirects to responses_path " do
      expect do
        post :create, :params => {
          :response => {
            name: 'new_response',
            enabled: '1',
            visibility: '2',
            initial_status_ids: ['1'],
            final_status_id: '5',
            tracker_ids: ['1'],
            note: 'note for test'
          }
        }
      end.to change { Response.count }.by(1)
      response = Response.last

      expect(response).to redirect_to('/responses')
      expect(response.name).to eq('new_response')
      expect(response.project).to be_nil
    end
  end

  describe "POST add" do
    it "adds a response to this issue by changing the note before sending, but without changing the value of response's note" do
      expect do
        post :add, params: {
          response_id: '4',
          issue_id: '1',
          response_new_note: 'newnote'
        }
      end.to change { Journal.count }.by(1)
      expect(Journal.last.notes).to eq('newnote')
      expect(Response.find(4).note).to eq('Thank you.')
    end

    it "does not add a note to the issue when the response is not included in available_responses" do
      expect do
        post :add, params: {
          response_id: '1',
          issue_id: '1',
          response_new_note: 'newnote'
        }
      end.to_not change { Journal.count }
    end
  end

  describe "test permission" do
    before do
      @request.session[:user_id] = 2
    end

    it "is not available when the user does not have the permission(create_prefabricated_responses)" do
      get :new, params: { project_id: project_1.id }
      expect(response).to have_http_status(:forbidden)
    end

    it "is available only when user has the permission(create_prefabricated_responses)" do
      role = user_2.roles_for_project(project_1).first
      role.add_permission! :create_prefabricated_responses
      get :new, params: { project_id: project_1.id }
      expect(response).to have_http_status(:success)
    end

    it "is not available when the user does not have the permission(edit_public_responses)" do
      get :edit, params: { id: '7' }
      expect(response).to have_http_status(:forbidden)
    end

    it "is available only when user has the permission(edit_public_responses)" do
      @request.session[:user_id] = 1
      get :edit, params: { id: '7' }
      expect(response).to have_http_status(:success)
    end

    it "does not show delete link when the user does not have the permission(delete_public_responses)" do
      role = Role.find(2)
      role.add_permission! :create_prefabricated_responses
      member = MemberRole.new(:member_id => 1, :role_id => 2)
      member.save
      get :index, params: { project_id: project_1.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:responses).count).to eq(3)
      assert_select "a[href='/responses/7'][data-method='delete']", 0
    end

    it "shows delete link when the user has the permission(delete_public_responses)" do
      role = Role.find(2)
      role.add_permission! :create_prefabricated_responses
      role.add_permission! :delete_public_responses
      member = MemberRole.new(:member_id => 1, :role_id => 2)
      member.save
      get :index, params: { project_id: project_1.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:responses).count).to eq(3)
      assert_select "a[href='/responses/7'][data-method='delete']", 1
    end

    it "does not show response visibility options when the user does not have the permission(manage_public_responses)" do
      role = user_2.roles_for_project(project_1).first
      role.add_permission! :create_prefabricated_responses
      get :new, params: { project_id: project_1.id }

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include('class=\"block role-visibility\"')
    end

    it "shows response visibility options only when user has the permission(manage_public_responses)" do
      role = user_2.roles_for_project(project_1).first
      role.add_permission! :create_prefabricated_responses
      role.add_permission! :manage_public_responses
      get :new, params: { project_id: project_1.id }

      expect(response).to have_http_status(:success)
      assert_response :success
      assert_select "label[class='block role-visibility']"
      expect(response.body).to include('class="block role-visibility"')
    end
  end

  describe "Responses index" do
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

      expect(response).to have_http_status(:success)
      expect(response.body).to include("All statues")
    end
  end
end
