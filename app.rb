require 'mongoid'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/assetpack'
require_relative 'app/models/subject'

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
  @subjects = Subject.all
end