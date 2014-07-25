require 'mongoid'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/assetpack'
require_relative 'app/models/subject'
require_relative 'app/models/item'

Mongoid.load!('config/mongoid.yml')

assets {
  js :app, [
    '/js/*.js'
  ]

  css :app, [
    '/css/*.css'
  ]
}

get '/' do
  @subjects = Subject.all.limit 10

  erb :index
end
