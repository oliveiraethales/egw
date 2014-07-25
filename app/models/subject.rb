require 'mongoid'

class Subject
  include Mongoid::Document

  field :name, type: String

  has_many :items
  has_one :subject
end