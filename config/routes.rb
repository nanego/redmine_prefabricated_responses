RedmineApp::Application.routes.draw do
  get 'responses/new(/:project_id)', controller: 'responses', action: 'new', as: 'new_response'
  resources :responses, :except => [:new] do
    collection do
      post :add
      post :apply
      post :update_note
    end
  end
end
