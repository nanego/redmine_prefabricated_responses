RedmineApp::Application.routes.draw do
  resources :responses do
    collection do
      post :add
      post :apply
    end
  end
end
