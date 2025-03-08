class CoursesController < ApplicationController
  def index
    @courses = Current.user.courses
  end
end