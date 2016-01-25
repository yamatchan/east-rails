class HomeController < ApplicationController
  def index
    redirect_to '/security' if session[:user_id].nil?
    @a = "A"
  end
end
