Rails.application.routes.draw do
  get '/current_user', to: 'current_user#index'

  resources :products
  resources :categories

  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :orders

end
