require 'mongoid'

class Item
  include Mongoid::Document

  field :text, type: String
  field :books, type: String

  belongs_to :subject
end