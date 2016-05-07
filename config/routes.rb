Rails.application.routes.draw do
  resource_id_regex  = /[a-zA-Z0-9\.%#\$&\?\(\)\=\+\-\_\:\?\\]+/
  uuid_regex         = /[a-zA-Z0-9\-]+/
  res_options        = { id: resource_id_regex }
  uuid_options       = { id: uuid_regex }
  root :to => 'feeds#index'

  resources :user_sessions
  resources :users do
    resources :entries, only: [:index], constraints: res_options
    resources :preferences, except: [:show]
  end
  resources :entries do
    get 'feedly', action: :show_feedly, on: :member
    resources :tracks, only: :index
  end
  resources :user_entries, only: [:create, :destroy]
  resources :feeds, constraints: res_options, shallow: true do
    get 'feedly', action: :show_feedly, on: :member
    resources :entries, only: [:index], constraints: uuid_options
  end

  resources :topics do
    resources :feeds, only: [:index]
  end
  resources :subscriptions
  resources :categories do
    resources :subscriptions, only: [:index]
  end
  resources :tracks
  resources :likes
  resources :tags do
    resources :entries, only: [:index]
  end

  get  'login'  => 'user_sessions#new'    , :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  scope :v3 do
    use_doorkeeper
  end

  namespace :v3 do
    resources :profile, only: [] do
      collection do
        get '' => 'credentials#me'
        put '' => 'users#create'
      end
    end

    resources :preferences, only: [:index] do
      post '', action: 'update', on: :collection
    end

    post '/markers' => 'markers#mark'

    resources :streams, only: [], constraints: res_options do
      member do
        get 'ids',      action: :index
        get 'contents', action: :index

        get 'tracks/ids'      => 'streams/tracks#index'
        get 'tracks/contents' => 'streams/tracks#index'
      end
    end

    resources :feeds, only: [:show], constraints: res_options do
      post '.mget', action: :list, on: :collection
    end
    get '/search/feeds'         => 'feeds#search'

    resources :topics, only: [:index, :destroy], constraints: res_options do
      post '', action: :update, on: :member
    end

    resources :entries, only: [:show], constraints: res_options do
      post '.mget', action: :list, on: :collection
    end

    resources :subscriptions, only: [:index, :create, :destroy], constraints: res_options

    resources :categories, only: [:index, :destroy], constraints: res_options do
      post '', action: :update, on: :member
    end

    resources :tracks,        only: [:show], constraints: { id: uuid_regex } do
      post '.mget', action: :list, on: :collection
    end
  end
end
