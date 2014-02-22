class SubjectsController < ApplicationController
  respond_to :json

  def index
    @subjects = Subject.all

    render json: @subjects
  end

  def process_files
    job = Job.where(description: 'process_files').first

    if job
      if job.status == 'complete'
        job.destroy

        render :process_files, text: 'complete!!'
      else
        render :process_files, text: "already processing: #{job.job_id} | status: #{job.status} | progress: #{job.progress}"
      end
    else
      job_description = 'process_files'
      job_id = FileProcessWorker.perform_async(job_description)

      render :process_files, text: "processing: " + job_id
    end
  end

  def show
  end
end