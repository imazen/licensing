Rails.application.routes.draw do
  post '/chargebee' => 'chargebee#index', as: :chargebee_index
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
