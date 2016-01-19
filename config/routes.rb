Rails.application.routes.draw do
  root :to => 'users#index'
  resources :user_sessions
  resources :users


  resources :feeds, except: [:show],
                    constraints: { id: /[a-zA-Z1-9\.%#\$&\?\(\)\=\+\-\:\?\/\\]+/ }

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
end
