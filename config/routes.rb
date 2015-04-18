Rails.application.routes.draw do
  post 'mails/notes'

  post 'mails/unsubscriptions'

  get 'user' => 'users#get_current_user'

  resources :sessions, only: [:create] do
    post :emails, action: :send_login_mail, on: :collection
  end

  resources :users, only: [:create, :show, :update, :destroy] do
    member do
      put :subscription, action: :subscribe
      delete :subscription, action: :unsubscribe

      post :regain, action: :cancel_destroy

      post :change_email_applies, action: :apply_change_email
      put :email, action: :change_email
    end
  end

  resources :diaries, only: [:show]

  resources :notes, only: [:create]

  root 'errors#not_found'
  # From http://stackoverflow.com/questions/24235805/rails-4-how-do-i-create-a-custom-404-page-that-uses-the-asset-pipeline#answer-26286472
  get 404, to: 'errors#not_found', code: 404
  get 500, to: 'errors#internal_server_error', code: 500
  get 503, to: 'errors#service_unavailable', code: 503

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
