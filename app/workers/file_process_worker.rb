class FileProcessWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options :retry => false

  def perform(name, count)
    puts "working on it nigga"
    get_letter_files_urls

    i = 0

    while i < count do
      puts "working on it +#{i}"
      i = i + 1
    end
  end

  private
    def get_letter_files_urls
      letter_files = 'A'..'Z'
      base_url = ENV["base_letter_files_url"]
      urls = []

      letter_files.each {|l| 
        urls << l + '.txt'
      }
    end
end