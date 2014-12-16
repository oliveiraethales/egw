require 'mongoid'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/assetpack'
require_relative 'app/models/topic'
require_relative 'app/models/subject'

require 'sinatra/reloader' if development?

Mongoid.load!('config/mongoid.yml')

assets {
  css :app, [
    '/css/*.css'
  ]

  js :app, [
    '/js/jquery.js',
    '/js/main.js'
  ]
}

get '/' do
  @topic_count = Topic.count

  erb :'topics/index'
end

get '/search' do
  @topics = Topic.where(name: /#{params[:search]}/i)

  erb :'topics/index'
end

get '/topics/:query' do
  @topics = Topic.where(name: /^#{params[:query]}/i)

  erb :'topics/index'
end

get '/topics/:index' do
  @topic = Topic.where(index: params[:index])

  erb :'topics/show'
end

helpers do
  def references(text)
    if text.include? ';'
      references_markup = ""

      # contains more than one book reference
      text_references = text.split ';'
      first_ref = text_references.first
      non_first = text_references.drop 1

      references_markup += first_reference(first_ref)

      non_first.each { |ref|
        references_markup += non_first_reference ref
      }

      return references_markup += "</p>"
    else
      # contains one or none references
      if text[0] =~ /\d/
        # first char is number, it is not a reference
        return "<p>#{text}</p>"
      else
        return first_reference(text) + "</p>"
      end
    end
  end

  def non_first_reference(reference)
    "<span class='reference'>#{reference.strip}</span>; "
  end

  def first_reference(reference)
    reference_markup = ''
    text = reference

    # iterate through the characters until at least
    # two capital letters are found and then a space (backwards)
    chars = reference.split(//)
    previous_was_capital_letter = false

    chars.reverse.each do |c|
      if previous_was_capital_letter && c == ' '
        # end of first reference
        break
      elsif ('A'..'Z').include? c
        # capital letter found
        previous_was_capital_letter = true
        reference_markup += c
      else
        reference_markup += c
      end
    end

    text.sub!(reference_markup.reverse, '')

    "<p>#{text}<span class='reference'>#{reference_markup.reverse}</span>; "
  end
end
