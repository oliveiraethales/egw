class Chapter
  include Mongoid::Document

  field :name, type: String
  field :content, type: String

  embedded_in :book
end