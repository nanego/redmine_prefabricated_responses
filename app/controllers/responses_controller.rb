class ResponsesController < ApplicationController

  def index
    @responses = Response.sorted
    @responses = @responses.visible_by(User.current) unless User.current.admin?
    respond_to do |format|
      format.html { render :layout => User.current.admin? ? 'admin' : 'base' }
    end
  end

  def show
    @response = Response.find(params[:id])
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
          redirect_to responses_path
        }
      end
    else
      respond_to do |format|
        format.html { render :action => :new }
      end
    end
  end

  def edit
    @response = Response.find(params[:id])
  end

  def update
    @response = Response.find(params[:id])
    @response.safe_attributes = params[:response]
    complete_response_attributes

    if @response.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_response_successfully_updated)
          redirect_to responses_path
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
    response = Response.find(params[:response_id])
    render :json => {
      :note => response.note
    }
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
end
