Rails.application.routes.draw do

  root 'homes#index'
  devise_for :users, path: 'accounts'
  match 'users/:id' => 'users#destroy', :via => :delete, :as => :admin_destroy_user

  resources :users, only: [:show, :index] do
    resources :bots, only: [:show]
  end

  resources :bots, except: [:show, :index] do
    resources :bots_interactions
    get '/reset', to: 'bots#reset'
  end


  resources :users, only: [:none] do
    resources :interactions, except: [:show]
  end

  post "/twilio/answer" => "twilio#answer"
end
