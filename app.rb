require 'mongoid'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/assetpack'
require_relative 'app/models/subject'
require_relative 'app/models/item'

require 'sinatra/reloader' if development?

Mongoid.load!('config/mongoid.yml')

assets {
  js :app, [
    '/js/jquery.js'
  ]
}

get '/' do
  erb :'subjects/index'
end

get '/search' do
  @subjects = Subject.where(name: /^#{params[:search]}/i)

  erb :'subjects/index'
end

get '/subjects/:query' do
  @subjects = Subject.where(name: /^#{params[:query]}/i)

  erb :'subjects/index'
end

get '/subject/:id' do
  @subject = Subject.find(params[:id])

  erb :'subjects/show'
end

get '/subjects.json' do
  skip = params[:page] * 50

  @subjects = Subject.skip(page).limit(50)

  json @subjects
end
