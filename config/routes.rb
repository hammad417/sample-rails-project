# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :admins, ActiveAdmin::Devise.config
  mount Sidekiq::Web => "/sidekiq"
  root to: 'admin/dashboard#index'
  ActiveAdmin.routes(self)

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :app_authorizations, only: [] do
        put :refresh_token, on: :collection
      end

      resources :documents, only: %i[create] do
        collection do
          get :get_documents
          get :get_document_list
          post :update_documents
          post :replace_documents
          post :remove_documents
        end
      end
    end
  end
  resources :aws, only: [] do
    collection do
      post :email_sns_hook
    end
  end
  resources :file_servers, only: [] do
    collection do
      get :serve_file
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
