class MoviesController < ApplicationController

  def show
    id = params[:id]
    @movie = Movie.find(id)
  end

  def index
    @all_ratings = Movie.all_ratings
    
    
    if params[:ratings].nil? && params[:sort].nil? && (session[:ratings].present? || session[:sort].present?)
      
      params[:ratings] = session[:ratings] if session[:ratings].present?
      params[:sort] = session[:sort] if session[:sort].present?
    end
    
   
    if params[:ratings].present?
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = params[:ratings]
    else
      @ratings_to_show = @all_ratings
      session[:ratings] = Hash[@all_ratings.map { |r| [r, "1"] }]
    end
    
    
    @movies = Movie.with_ratings(@ratings_to_show)
    
    
    if params[:sort].present?
      @sort_by = params[:sort]
      @movies = @movies.order(@sort_by)
      session[:sort] = params[:sort]
    else
      @sort_by = nil
      session.delete(:sort)
    end
  end

  def new
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end