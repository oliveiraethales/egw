class User
  include Mongoid::Document

  has_secure_password

  field :name, type: String
  field :email, type: String, default: ""
  field :password_digest, type: String, default: ""

  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :password_digest
end