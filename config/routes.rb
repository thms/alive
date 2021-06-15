Rails.application.routes.draw do
  resources :dinosaurs
  resources :matches
  resources :simulations
  resources :abilities
  resources :team_matches
end
