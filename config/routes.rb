Gearstack::Application.routes.draw do

  devise_for :users

  root :to => "home#index"

  scope '/api' do
    resources :gear
  end
end
