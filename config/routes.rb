Gearstack::Application.routes.draw do

  devise_for :users

  root :to => "home#index"

  # scope '/api' do
  #   resources :gear
  # end

  # namespace the api, so that when we make changes in the future things don't totally break
  namespace :api do
  	namespace :v1 do
  		resources :gear_items
  	end
  end

  # need this again so we get in-app functions like 'gear_item_url'
  resources :gear_items
end
