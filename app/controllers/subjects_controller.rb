class SubjectsController < ApplicationController
  respond_to :json

  def index
    @subjects = Subject.all

    render json: @subjects
  end

  def process_files
    job = Job.where(description: 'process_files').first

    if job
      job.status = Sidekiq::Status::status(job.job_id).to_s
      job.save

      if job.status == 'complete'
        job.destroy

        render :process_files, text: 'complete!!'
      else
        render :process_files, text: "already processing: " + job.job_id + "| status: " + job.status
      end
    else
      get_letter_files_urls()

      job_id = FileProcessWorker.perform_async('lulz', 30000)
      job = Job.new(job_id: job_id, description: 'process_files', status: 'just started')
      job.save

      render :process_files, text: "processing: " + job_id
    end
  end

  def show
  end
end