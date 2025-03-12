class CoursesController < ApplicationController
  def index
    @courses = Current.user.courses
  end

  def show
    @course = Current.user.courses.find(params[:id])
  end
end
