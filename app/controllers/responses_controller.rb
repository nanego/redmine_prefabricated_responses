# frozen_string_literal: true

class ResponsesController < ApplicationController
  before_action :find_optional_project, :only => [:index, :new, :create]
  before_action :find_response, :only => [:show, :edit, :update, :destroy]
  before_action :require_admin_or_author, :only => [:edit, :update]
  before_action :require_delete_permission, :only => [:destroy]
  before_action :require_global, :only => [:show]

  def index
    @responses = Response.sorted
    if @project
      @responses = @responses.global_for_project(User.current, @project.id)
    else
      @responses = @responses.owned_without_project(User.current)
    end
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
        format.html do
          flash[:notice] = l(:notice_response_successfully_created)
          redirect_to responses_path if @response.project.blank?
          redirect_to project_responses_path(@response.project.id) if @response.project.present?
        end
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
        format.html do
          flash[:notice] = l(:notice_response_successfully_updated)
          # redirect_to responses_path
          redirect_to responses_path if @response.project.blank?
          redirect_to project_responses_path(@response.project.id) if @response.project.present?
        end
      end
    else
      respond_to do |format|
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @response.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = l(:notice_response_successfully_deleted)
        redirect_to(:back)
      end
    end
  end

  def add
    return if params[:response_id].blank?

    issue = Issue.find(params[:issue_id])
    response = Response.find(params[:response_id])
    response.note = params[:response_new_note]
    if issue.available_responses(User.current).include?(response)
      saved = issue.add_response(response, User.current)
    end
    if saved
      redirect_to issue, :notice => l(:notice_response_successfully_added)
    else
      redirect_to issue, :alert => l(:notice_response_not_added)
    end
  end

  def apply
    @issue = Issue.find(params[:issue_id])
    @response = Response.find(params[:response_id])
    return render_403 unless @issue.available_responses(User.current).include?(@response)
  end

  def update_note
    @issue = Issue.find(params[:issue_id])
    @response = Response.find(params[:response_id])
    return render_403 unless @issue.available_responses(User.current).include?(@response)

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
    unless User.current.admin? || @response.author == User.current || User.current.allowed_to?(:edit_public_responses, @response.project)
      render_403
      return false
    end
    true
  end

  def require_delete_permission
    unless User.current.admin? || @response.author == User.current || User.current.allowed_to?(:delete_public_responses, @response.project)
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
      global = Response.owned_without_project(User.current).include?(@response)
    end

    render_403 unless global
  end
end
