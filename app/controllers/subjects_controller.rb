class SubjectsController < ApplicationController
  respond_to :json

  def index
    @subjects = Subject.all

    render json: @subjects
  end

  def process_files
    a = FileProcessWorker.perform_async('lulz', 5)

    render :process_files, json: a
  end

  def show
  end
end