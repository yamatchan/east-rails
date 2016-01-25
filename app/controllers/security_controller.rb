class SecurityController < ApplicationController
  def index

  end

  def login
  	user = User.where(id_str: params[:login][:id_str]).first

    if user then
      session[:user_id] = user.id
#      render :text => user.id
      redirect_to '/home'
    else
      redirect_to '/security'
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to '/security'
  end
end
