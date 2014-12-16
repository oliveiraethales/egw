require 'mongoid'

class Subject
  include Mongoid::Document

  field :name, type: String

  embedded_in :topic
end
