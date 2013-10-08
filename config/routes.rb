require 'resque/server'

auth_resque = ->(request) {
  request.env['warden'].authenticate? and request.env['warden'].user.admin?
}

Ontohub::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "users/registrations" }
  resources :users, :only => :show
  resources :keys, except: [:show, :edit, :update]
  
  resources :logics do
    resources :supports, :only => [:create, :update, :destroy, :index]
    resources :graphs, :only => [:index]
  end
  
  resources :languages do
    resources :supports, :only => [:create, :update, :destroy, :index]
  end
  
  resources :language_mappings
  resources :logic_mappings

  resource :links

  resources :language_adjoints
  resources :logic_adjoints

  resources :serializations

  namespace :admin do
    resources :teams, :only => :index
    resources :users
    resources :jobs, :only => :index
  end

  constraints auth_resque do
    mount Resque::Server, :at => "/admin/resque"
  end
  
  resources :teams do
    resources :permissions, :only => [:index], :controller => 'teams/permissions'
    resources :team_users, :only => [:index, :create, :update, :destroy], :path => 'users'
  end
  
  get 'autocomplete' => 'autocomplete#index'
  get 'symbols'      => 'search#index'

  resources :repositories do
    resources :permissions, :only => [:index, :create, :update, :destroy]

    resources :ontologies, only: [:index, :show, :edit, :update] do
      resources :children, :only => :index
      resources :entities, :only => :index
      resources :sentences, :only => :index
      resources :ontology_versions, :only => [:index, :show, :new, :create], :path => 'versions' do
        resource :oops_request, :only => [:show, :create]
      end

      resources :metadata, :only => [:index, :create, :destroy]
      resources :comments, :only => [:index, :create, :destroy]
      resources :graphs, :only => [:index]
    end

    resources :files, only: [:new, :create]
    # action: history, diff, entries_info, files
    get ':ref/:action(/:path)',
      controller:  :files,
      as:          :ref,
      constraints: { path: /.*/ }
  end

  get ':repository_id(/:path)',
    controller:  :files,
    action:      :files,
    as:          :repository_tree,
    constraints: proc { |request|
      params = request.send(:env)["action_dispatch.request.path_parameters"]

      path  = params[:path]
      path += ".#{params[:format]}" if params[:format]

      result = path.nil? || Repository.find_by_path(params[:repository_id]).
        path_exists?(path)

      if result
        params[:path] = path
        params[:format] = nil
      end

      result
    }

  get ':repository_id/:id',
    controller:  :ontologies,
    action:      :show,
    as:          :ontology_tree do 
      resources :entities, :only => :index
    end

  root :to => 'home#show'

end
