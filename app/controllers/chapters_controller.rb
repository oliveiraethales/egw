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
    @book = Book.find_by(name: params[:chapter][:book_name])
    @book.chapters << @chapter

    if @book.save
      redirect_to @book, notice: "Chapter '#{@chapter.name}' added to '#{@book.name}' book!"
    end
  end

  private
    def chapter_params
      params.require(:chapter).permit(:name, :content)
    end
end