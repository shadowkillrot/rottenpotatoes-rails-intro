class MoviesController < ApplicationController

  def show
    id = params[:id]
    @movie = Movie.find(id)
  end

  def index
  @all_ratings = Movie.all_ratings
  
  # Check if we need to restore from session and redirect
  redirect_needed = false
  
  if params[:ratings].nil? && session[:ratings].present?
    params[:ratings] = session[:ratings]
    redirect_needed = true
  end
  
  if params[:sort_by].nil? && session[:sort_by].present?
    params[:sort_by] = session[:sort_by]
    redirect_needed = true
  end
  
  # If we restored from session, redirect to RESTful URL with params visible
  if redirect_needed
    redirect_to movies_path(sort_by: params[:sort_by], ratings: params[:ratings]) and return
  end
  
  # Handle ratings filter
  if params[:ratings].present?
    @ratings_to_show = params[:ratings].keys
    session[:ratings] = params[:ratings]
  else
    @ratings_to_show = @all_ratings
    session[:ratings] = Hash[@all_ratings.map { |r| [r, "1"] }]
  end
  
  # Get movies with ratings filter
  @movies = Movie.with_ratings(@ratings_to_show)
  
  # Handle sorting
  if params[:sort_by].present?
    @sort_by = params[:sort_by]
    @movies = @movies.order(@sort_by)
    session[:sort_by] = params[:sort_by]
  else
    @sort_by = nil
    session.delete(:sort_by)
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