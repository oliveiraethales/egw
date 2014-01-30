class FileProcessWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options :retry: false

  def perform(name, count)
    puts "working on it nigga"

    return "lulz!!!11!"
  end
end