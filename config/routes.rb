Risker::Application.routes.draw do
  resources :sessions,      only: [:new, :create, :destroy]
  resources :users,         only: [:show, :create]
  resources :projects,      only: [:show, :new, :create, :destroy]
  resources :risks,         only: [:show, :new, :create, :update, :destroy] do
    member do
      get 'checking'
    end
  end

  resources :cost_comments, only: [:create, :destroy]
  root 'static_pages#root'
  match '/history', to: 'static_pages#history', via: 'get'
  match '/counter', to: 'static_pages#counter', via: 'get'
  match '/signup', to: 'users#new', via: 'get'
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'
  match '/password_reset_request/', to: 'password_reset_hashs#show', via: 'get'
  match '/password_reset_request/', to: 'password_reset_hashs#create', via: 'post'
  match '/password_reset/',         to: 'password_reset_hashs#edit', via: 'get'
  match '/password_reset/',         to: 'password_reset_hashs#update', via: 'patch'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
