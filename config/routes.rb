Rails.application.routes.draw do
  root :to => 'feeds#index'
  resources :user_sessions
  resources :users

  resources :feeds, constraints: { id: /[a-zA-Z1-9\.%#\$&\?\(\)\=\+\-\:\?\\]+/ },
                    shallow: true do
    resources :entries, only: [:index], constraints: { id: '/[a-zA-Z1-9\-]+/'}
  end
  resources :entries

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
end
