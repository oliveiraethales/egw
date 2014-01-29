class FileProcessWorker
  include Sidekiq::Worker

  def perform(name, count)
    puts "working on it nigga"
  end
end