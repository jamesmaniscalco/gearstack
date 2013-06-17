Gearstack::Application.routes.draw do

  devise_for :users, :controllers => {registrations: 'registrations'}  # for the API

  root :to => "home#index"  # use the home controller for any pages that won't be powered by the JS frontend

  resources :gear           # only responding to json

end
