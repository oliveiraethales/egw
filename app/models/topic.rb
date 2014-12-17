require 'mongoid'

class Topic
  include Mongoid::Document

  field :name, type: String
  field :index, type: Integer

  def subjects
    Subject.where(topic_index: index)
  end
end
