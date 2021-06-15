Rails.application.routes.draw do
  resources :dinosaurs
  resources :matchups
  resources :simulations
  resources :abilities
  resources :team_matches
end
