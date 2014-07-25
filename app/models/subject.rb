require 'mongoid'

class Subject
  include Mongoid::Document

  field :name, type: String

  embeds_many :items
end
