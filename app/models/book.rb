class Book
  include Mongoid::Document

  field :name, type: String

  embeds_many :chapters
end