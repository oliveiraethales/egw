require 'mongoid'

class Subject
  include Mongoid::Document

  field :name, type: String
  field :topic_index, type: Integer
end
