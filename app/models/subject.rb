require 'mongoid'

class Subject
  include Mongoid::Document

  field :name, type: String

  belongs_to :topic
end
