class SubjectsController < ApplicationController
  respond_to :json

  def index
    @subjects = Subject.all

    render json: @subjects
  end

  def process_files
    Job.find(job_id: a)

    a = FileProcessWorker.perform_async('lulz', 5)

    if Job.create(job_id: a)

    render :process_files, json: a
  end

  def show
  end
end