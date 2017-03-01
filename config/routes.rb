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
  resources :saved_entries, only: [:create, :destroy]
  resources :read_entries , only: [:create, :destroy]
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
  resources :tracks do
    resources :likes, controller: :track_likes, as: :likes, only: [:create, :destroy]
  end
  resources :keywords do
    resources :entries, only: [:index]
  end
  resources :tags do
    resources :entries, only: [:index]
  end
  resources :journals do
    resources :issues
  end
  resources :issues, only: []  do
    resources :entry_issues, only: [:new, :edit, :update, :destory]
  end
  resources :entry_issues, only: [:create, :update, :destroy, :edit]

  get  'login',  to: 'user_sessions#new'    , :as => :login
  post 'logout', to: 'user_sessions#destroy', :as => :logout

  scope :v3 do
    use_doorkeeper
  end

  namespace :v3 do
    resources :profile, only: [] do
      collection do
        get '', to: 'credentials#me'
        put '', to: 'users#create'
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

        get ':enclosures/ids'      => 'streams/enclosures#index'
        get ':enclosures/contents' => 'streams/enclosures#index'
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

    resources :tracks, only: [:show], constraints: uuid_options do
      post '.mget', action: :list, on: :collection
    end

    resources :keywords, only: [:index, :destroy], constraints: res_options do
      post '', action: :update, on: :member
    end

    resources :tags, only: [:index], constraints: res_options do
      id_list_regex = /[a-zA-Z0-9\.\,%#\$&\?\(\)\=\+\-\_\:\?\\]+/
      c             = { tag_ids: id_list_regex, entry_ids: id_list_regex }
      post '', action: :update, on: :member
      collection do
        put    ':tag_ids'           , action: :tag_entry    , constraints: c
        put    ':tag_ids/:entry_ids', action: :tag_entries  , constraints: c
        delete ':tag_ids/:entry_ids', action: :untag_entries, constraints: c
        delete ':tag_ids'           , action: :destroy      , constraints: c
      end
    end
  end
end
