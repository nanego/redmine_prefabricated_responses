RedmineApp::Application.routes.draw do
  get 'responses/new', to: 'responses#new', as: 'new_response'
  get 'projects/:project_id/responses/new', to: 'responses#new', as: 'project_new_response'

  get 'responses/', to: 'responses#index', as: 'responses'
  get 'projects/:project_id/responses/', to: 'responses#index', as: 'project_responses'

  get 'response/:id', controller: 'responses', action: 'show', as: 'show_response'
  resources :responses, :except => [:new, :index, :show] do
    collection do
      post :add
      post :apply
      post :update_note
    end
  end
end
