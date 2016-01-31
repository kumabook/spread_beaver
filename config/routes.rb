Rails.application.routes.draw do
  use_doorkeeper
  root :to => 'feeds#index'
  resources :user_sessions
  resources :users
  resources :subscriptions, only: [:index]

  feed_id_regex = /[a-zA-Z1-9\.%#\$&\?\(\)\=\+\-\:\?\\]+/
  entry_id_regex = /[a-zA-Z1-9\-]+/
  resources :feeds, constraints: { id: feed_id_regex },
                    shallow: true do
    resources :entries, only: [:index], constraints: { id: entry_id_regex }
  end
  resources :entries

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
end
