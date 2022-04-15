class ResponsesController < ApplicationController

  before_action :find_optional_project, :only => [:index, :new, :create]
  before_action :find_response, :only => [:show, :edit, :update, :destroy]
  before_action :require_admin_or_author, :only =>[:edit]
  before_action :require_global, :only =>[:show]

  def index
    # #### TODO (using project_id or identifier) to discuss
    if params[:project_id].present?
      return @responses = [] unless Project.find(params[:project_id]).id.to_s == params[:project_id]
    end
    # ##############
    @responses = Response.sorted
    @project_id = params[:project_id]
    @responses = @responses.private_for_user(User.current) unless @project_id.present?
    @responses = @responses.global_for_project(User.current, params[:project_id]) if @project_id.present?
    respond_to do |format|
      format.html { render :layout => User.current.admin? ? 'admin' : 'base' }
    end
  end

  def show

    @initial_statuses = IssueStatus.where(id: @response.initial_status_ids)
    @final_status = IssueStatus.find_by_id(@response.final_status_id)

  end

  def new
    @response = Response.new
    @response.project = params[:project_id] ? Project.find(params[:project_id]) : nil
  end

  def create
    @response = Response.new
    @response.author = User.current
    @response.project = params[:response][:project_id].present? ? Project.find(params[:response][:project_id]) : nil
    @response.safe_attributes = params[:response]
    complete_response_attributes

    if @response.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_response_successfully_created)
          redirect_to responses_path unless @response.project.present?
          redirect_to project_responses_path(@response.project.id) if @response.project.present?
        }
      end
    else
      respond_to do |format|
        format.html { render :action => :new }
      end
    end
  end

  def edit

  end

  def update
    @response.safe_attributes = params[:response]
    complete_response_attributes

    if @response.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_response_successfully_updated)
          #redirect_to responses_path
          redirect_to responses_path unless @response.project.present?
          redirect_to project_responses_path(@response.project.id) if @response.project.present?
        }
      end
    else
      respond_to do |format|
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @response = Response.find(params[:id])
    @response.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_response_successfully_deleted)
        redirect_to(:back)
      }
    end
  end

  def add
    return unless params[:response_id].present?

    issue = Issue.find(params[:issue_id])
    response = Response.find(params[:response_id])
    response.note = params[:response_new_note]
    if issue.available_responses(User.current).include?(response)
      issue.add_response(response, User.current)
    end
    redirect_to issue
  end

  def apply
    @issue = Issue.find(params[:issue_id])
    @response = Response.find(params[:response_id])
  end

  def update_note
    @response = Response.find(params[:response_id])
    @issue = Issue.find(params[:issue_id])
    respond_to do |format|
      format.js
    end
  end

  private

  def complete_response_attributes
    if User.current.allowed_to?(:manage_public_responses, @response.project) || User.current.admin?
      @response.visibility = (params[:response] && params[:response][:visibility]) || Response::VISIBILITY_PRIVATE
      @response.role_ids = params[:response] && params[:response][:role_ids]
    else
      @response.visibility = Response::VISIBILITY_PRIVATE
    end
  end

  def require_admin_or_author

    if !(User.current.admin? || @response.author == User.current)
      render_403
      return false
    end
    true
  end

  def find_response
    return unless require_login

    @response = Response.find(params[:id])

    rescue ActiveRecord::RecordNotFound
      render_404
  end

  def require_global
    if @response.project.present?
      global = Response.global_for_project(User.current, @response.project.id).include?(@response)
    else
      global = Response.private_for_user(User.current).include?(@response)
    end

    render_403 unless global

  end
end
