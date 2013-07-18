class ChaptersController < ApplicationController
  def index

  end

  private
    def chapter_params
      params.require(:chapter).permit(:name, :content)
    end
end