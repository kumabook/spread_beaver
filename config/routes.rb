Rails.application.routes.draw do
  feed_id_regex  = /[a-zA-Z0-9\.%#\$&\?\(\)\=\+\-\:\?\\]+/
  uuid_regex     = /[a-zA-Z0-9\-]+/
  root :to => 'feeds#index'

  resources :user_sessions
  resources :users do
    resources :entries, only: [:index], constraints: { id: uuid_regex }
  end
  resources :entries do
    resources :tracks, only: :index
  end
  resources :user_entries, only: [:create, :destroy]
  resources :feeds, constraints: { id: feed_id_regex },
                    shallow: true do
    resources :entries, only: [:index], constraints: { id: uuid_regex }
  end
  resources :subscriptions, only: [:create, :destroy]
  resources :tracks
  resources :likes

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  scope :v3 do
    use_doorkeeper
  end

  namespace :v3 do
    get  '/profile'  => 'credentials#me'
    put  '/profile'  => 'users#create'
    post '/markers'  => 'markers#mark'
    get  '/streams/:id/ids'      => 'streams#index', constraints: { id: feed_id_regex }
    get  '/streams/:id/contents' => 'streams#index', constraints: { id: feed_id_regex }
    get  '/search/feeds'         => 'feeds#search'
    resources :feeds,         only: [:show], constraints: { id: feed_id_regex }
    post  '/feeds/.mget'         => 'feeds#list'
    resources :subscriptions, only: [:index, :create, :destroy], constraints: { id: feed_id_regex }
    resources :tracks,        only: [:show], constraints: { id: uuid_regex }
    post  '/tracks/.mget'        => 'tracks#list'
  end
end
