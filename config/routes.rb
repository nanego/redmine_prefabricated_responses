RedmineApp::Application.routes.draw do
  resources :responses do
    collection do
      post :add
      post :apply
      post :update_note
    end
  end
end
