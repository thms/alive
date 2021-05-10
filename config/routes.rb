Rails.application.routes.draw do
  resources :dinosaurs
  resources :matchups
  resources :simulations
  resources :abilities
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
