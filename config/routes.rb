# frozen_string_literal: true

Rails.application.routes.draw do
  resource_id_regex  = /[a-zA-Z0-9\.%#\$&\?\(\)\=\+\-\_\:\\]+/
  uuid_regex         = /[a-zA-Z0-9\-]+/
  res_options        = { id: resource_id_regex }
  uuid_options       = { id: uuid_regex }
  root to: "feeds#index"

  resources :user_sessions, only: [:create]
  get  "login",  to: "user_sessions#new"    , as: :login
  post "logout", to: "user_sessions#destroy", as: :logout
  get "/auth/:provider/callback", to: "authentications#callback"
  resources :users do
    resources :entries, only: [:index], constraints: res_options
    resources :preferences, except: [:show]
  end
  resources :authentications, only: [:destroy]
  resources :entries do
    get "feedly", action: :show_feedly, on: :member
    get "crawl" , action: :crawl      , on: :member
    resources :tracks   , controller: :enclosures, type: "Track"   , only: :index
    resources :albums   , controller: :enclosures, type: "Album"   , only: :index
    resources :playlists, controller: :enclosures, type: "Playlist", only: :index

    resources :tracks   , controller: :entry_enclosures, type: "Track"   , only: %i[new create destroy]
    resources :albums   , controller: :entry_enclosures, type: "Album"   , only: %i[new create destroy]
    resources :playlists, controller: :entry_enclosures, type: "Playlist", only: %i[new create destroy]

    post   "like"  , to: :like  , as: :likes
    delete "unlike", to: :unlike, as: :like
    post   "save"  , to: :save  , as: :saves
    delete "unsave", to: :unsave, as: :save
    post   "read"  , to: :read  , as: :reads
    delete "unread", to: :unread, as: :read
  end
  resources :entry_enclosures, only: %i[create edit update destroy]
  resources :read_entries , only: %i[create destroy]
  resources :feeds, constraints: res_options, shallow: true do
    get "feedly", action: :show_feedly, on: :member
    resources :entries, only: [:index], constraints: uuid_options
  end

  resources :topics do
    get "mix_issue", to: :mix_issue, as: :mix_issue
    resources :feeds, only: [:index]
  end
  resources :subscriptions, except: [:new]
  resources :categories do
    resources :subscriptions, only: [:index]
  end
  resources :tracks, controller: :enclosures, type: "Track", except: %i[edit update] do
    post   "like"  , to: :like  , as: :likes
    delete "unlike", to: :unlike, as: :like
    post   "save"  , to: :save  , as: :saves
    delete "unsave", to: :unsave, as: :save
    post   "play"  , to: :play  , as: :plays
    get    "search", on: :collection
  end
  resources :albums, controller: :enclosures, type: "Album", except: %i[edit update] do
    post   "like"  , to: :like  , as: :likes
    delete "unlike", to: :unlike, as: :like
    post   "save"  , to: :save  , as: :saves
    delete "unsave", to: :unsave, as: :save
    post   "play"  , to: :play  , as: :plays
    get    "search", on: :collection
  end
  resources :artists, controller: :enclosures, type: "Artist", except: %i[edit update] do
    post   "like"  , to: :like  , as: :likes
    delete "unlike", to: :unlike, as: :like
    post   "save"  , to: :save  , as: :saves
    delete "unsave", to: :unsave, as: :save
    post   "play"  , to: :play  , as: :plays
    get    "search", on: :collection
  end
  resources :playlists, controller: :enclosures, type: "Playlist", except: %i[edit update] do
    post   "like"  , to: :like  , as: :likes
    delete "unlike", to: :unlike, as: :like
    post   "save"  , to: :save  , as: :saves
    delete "unsave", to: :unsave, as: :save
    post   "play"  , to: :play  , as: :plays
    get    "search", on: :collection
    member do
      get "crawl"
      get "activate"
      get "deactivate"
    end
    get "actives"   , on: :collection
  end

  resources :track_identities   , controller: :identities, type: "TrackIdentity" do
    member do
      get "crawl"
    end
  end
  resources :album_identities   , controller: :identities, type: "AlbumIdentity" do
    member do
      get "crawl"
    end
  end
  resources :artist_identities  , controller: :identities, type: "ArtistIdentity" do
    member do
      get "crawl"
    end
  end

  resources :keywords do
    resources :entries, only: [:index]
  end
  resources :tags do
    resources :entries, only: [:index]
  end
  resources :walls do
    resources :resources, only: [:new]
  end
  resources :resources,  only: %i[create edit update destroy]
  resources :journals do
    resources :issues do
      post "daily", action: :create_daily, on: :collection
      post "collect_entries", action: :collect_entries, on: :member
    end
  end
  resources :issues, only: []  do
    resources :entry_issues, only: [:new]
    resources :entries     , only: [:index]

    resources :enclosure_issues, only: [:new]
    resources :tracks   , controller: :enclosures, type: "Track"   , only: :index
    resources :albums   , controller: :enclosures, type: "Album"   , only: :index
    resources :playlists, controller: :enclosures, type: "Playlist", only: :index
  end
  resources :entry_issues    , only: %i[create edit update destroy]
  resources :enclosure_issues, only: %i[create edit update destroy]

  resources :mixes, only: %i[index show], constraints: res_options do
    member do
      get ":enclosures" => "mixes/enclosures#show"
    end
  end

  scope :v3 do
    use_doorkeeper
  end

  namespace :spotify do
    resources :tokens, only: [] do
      collection do
        post "swap"   , action: :swap
        post "refresh", action: :refresh
      end
    end
  end

  namespace :v3 do
    resources :profile, controller: :users, only: %i[show update] do
      collection do
        get  ""   , to: "users#me"
        put  ""   , to: "users#create"
        post ""   , to: "users#update"
        get "edit", to: "users#edit"
      end
      member do
        delete ":provider", to: "authentications#destroy"
      end
    end

    resources :preferences, only: [:index] do
      post "", action: "update", on: :collection
    end

    post "/markers" => "markers#mark"

    resources :walls, only: [], constraints: res_options do
      member do
        get "", action: :show
      end
    end

    resources :streams, only: [], constraints: res_options do
      member do
        get "ids",      action: :show
        get "contents", action: :show

        get ":enclosures/ids"      => "streams/enclosures#show"
        get ":enclosures/contents" => "streams/enclosures#show"
      end
    end

    resources :mixes, only: [], constraints: res_options do
      member do
        get "ids",      action: :show
        get "contents", action: :show

        get ":enclosures/ids"      => "mixes/enclosures#show"
        get ":enclosures/contents" => "mixes/enclosures#show"
      end
    end

    resources :feeds, only: [:show], constraints: res_options do
      post ".mget", action: :list, on: :collection
    end
    get "/search/feeds"         => "feeds#search"

    resources :topics, only: %i[index destroy], constraints: res_options do
      post "", action: :update, on: :member
    end

    resources :entries, only: [:show], constraints: res_options do
      post ".mget", action: :list, on: :collection
    end

    resources :subscriptions, only: %i[index create destroy], constraints: res_options

    resources :categories, only: %i[index destroy], constraints: res_options do
      post "", action: :update, on: :member
    end

    resources :tracks, controller: :enclosures, type: "Track",
                       only: [:show], constraints: uuid_options do
      post ".mget", action: :list, on: :collection
      resources :playlists, only: [:index], controller: :enclosures, type: "Playlist"
    end

    resources :albums, controller: :enclosures, type: "Album",
                       only: [:show], constraints: uuid_options do
      post ".mget", action: :list, on: :collection
    end

    resources :artists, controller: :enclosures, type: "Artist",
                        only: [:show], constraints: uuid_options do
      post ".mget", action: :list, on: :collection
    end

    resources :playlists, controller: :enclosures, type: "Playlist",
                          only: [:show], constraints: uuid_options do
      post ".mget", action: :list, on: :collection
      resources :tracks, only: [:index], controller: :enclosures, type: "Track"
    end

    resources :keywords, only: %i[index destroy], constraints: res_options do
      post "", action: :update, on: :member
    end

    resources :tags, only: [:index], constraints: res_options do
      id_list_regex = /[a-zA-Z0-9\.\,%#\$&\?\(\)\=\+\-\_\:\\]+/
      c             = { tag_ids: id_list_regex, entry_ids: id_list_regex }
      post "", action: :update, on: :member
      collection do
        put    ":tag_ids"           , action: :tag_entry    , constraints: c
        put    ":tag_ids/:entry_ids", action: :tag_entries  , constraints: c
        delete ":tag_ids/:entry_ids", action: :untag_entries, constraints: c
        delete ":tag_ids"           , action: :destroy      , constraints: c
      end
    end
  end
end
