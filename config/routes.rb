RedmineApp::Application.routes.draw do
  resources :responses do
    collection do
      post :add
    end
  end
end
