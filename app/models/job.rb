class Job
  include Mongoid::Document

  field :job_id, type: String
  field :description, type: String
  field :status, type: String
end