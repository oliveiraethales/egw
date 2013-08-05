class ChaptersController < ApplicationController
  def index
  end

  def show
    @book_name = params[:book_name]
    @chapters = Chapter.book.where(name: book_name)
  end

  def new
    @chapter = Chapter.new
    @book_name = params[:book_name]
  end

  def create
    @chapter = Chapter.new(chapter_params)
    @chapter.book = Book.where(name: params[:book_name])

    if @chapter.save
      redirect_to chapters_url, notice: 'Book saved!'
    end
  end

  private
    def chapter_params
      params.require(:chapter).permit(:name, :content)
    end
end