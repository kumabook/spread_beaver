Rails.application.routes.draw do
  feed_id_regex  = /[a-zA-Z1-9\.%#\$&\?\(\)\=\+\-\:\?\\]+/
  entry_id_regex = /[a-zA-Z1-9\-]+/
  use_doorkeeper
  root :to => 'feeds#index'
  resources :user_sessions
  resources :users do
    resources :entries, only: [:index], constraints: { id: entry_id_regex }
  end
  resources :entries do
    resources :tracks, only: :index
  end
  resources :feeds, constraints: { id: feed_id_regex },
                    shallow: true do
    resources :entries, only: [:index], constraints: { id: entry_id_regex }
  end
  resources :subscriptions, only: [:index, :create, :destroy]
  resources :tracks

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
end
