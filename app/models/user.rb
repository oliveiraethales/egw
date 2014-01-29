class User
  include Mongoid::Document

  field :name, type: String
  field :email, type: String, default: ""

  validates_presence_of :name
  validates_presence_of :email
end