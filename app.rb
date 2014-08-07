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
  erb :index
end

get '/subjects/:query' do
  if params[:query].length > 1
    pass
  end

  db = Mongoid::Sessions.default

  subjects_collection = db[:subjects]

  @letter = params[:letter]
  @subjects = Subject.where(letter: @letter)
  @letter_count = @subjects.count

  erb :index
end

get '/subjects/:query' do
  @subjects = Subject.where(  name: @letter)
end
