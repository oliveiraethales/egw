require 'mongoid'

class Topic
  include Mongoid::Document

  field :name, type: String
  field :index, type: Integer

  has_many :subjects
end
