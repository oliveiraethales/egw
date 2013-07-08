class Book
  include Mongoid::Document

  field :name, type: String
end