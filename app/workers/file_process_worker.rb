require 'open-uri'
require 'ruby-progressbar'

class FileProcessWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options :retry => false

  def perform(description)
    Subject.destroy_all
    job = Job.new
    logger.info "building urls"

    job.description = description
    job.status = "building urls"
    job.progress = "0"
    job.save

    urls = get_letter_files_urls

    job.status = "processing urls"
    job.progress = "1"
    job.save

    logger.info "processing: #{urls.count} urls"

    @progress_bar = ProgressBar.create

    urls.each {|url|
      logger.info "processing url: #{url}"

      job.status = "processing url: #{url}"
      job.save

      letter_file = open(url)

      lines = letter_file.readlines

      if lines.join.include?('<font')
        next
      end

      logger.info "processing #{lines.count} lines"

      lines.each {|l|
        subject = Subject.new
        subject.name = l[/[a-z]+/i]
        subject.save
      }

      job.progress = @progress_bar.increment
      job.save
    }

    job.status = 'complete'
    job.save
  end

  private
    def get_letter_files_urls
      letter_files = 'A'..'Z'
      base_url = ENV["base_letter_files_url"]
      urls = []

      letter_files.each {|l| 
        urls << "#{base_url}#{l}.txt"
      }

      urls
    end
end