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
  resources :user_entries, only: [:create, :destroy]
  resources :feeds, constraints: { id: feed_id_regex },
                    shallow: true do
    resources :entries, only: [:index], constraints: { id: entry_id_regex }
  end
  resources :subscriptions, only: [:create, :destroy]
  resources :tracks
  resources :likes

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  namespace :api, format: 'json' do
    namespace :v1 do
      get  '/me'       => 'credentials#me'
      post '/me'       => 'users#create'
      get  '/streams/:id/ids'      => 'streams#index', constraints: { id: feed_id_regex }
      get  '/streams/:id/contents' => 'streams#index', constraints: { id: feed_id_regex }
      resources :feeds,         only: [:index], constraints: { id: feed_id_regex }
      resources :subscriptions, only: [:index, :create, :destroy], constraints: { id: feed_id_regex }
      resources :likes,         only: [:index]
    end
  end
end
