RedmineApp::Application.routes.draw do

  resources :projects do
    resources :responses, :only => [:index, :new, :create]
  end

  resources :responses do
    collection do
      post :add
      post :apply
      post :update_note
    end
  end

end
