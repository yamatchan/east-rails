class InstanceController < ApplicationController
  def create
  	@images = Image.all
  	@image_names = @images.each_with_object({}) do |value, new_hash|
      logger.debug value
      new_hash[value.name] = value.id
  	end
  	logger.debug @image_names
  end

  def post_create
  	instance_cnt = Instance.where(user_id: session[:user_id]).count

    instance = Instance.new
    logger.debug instance
    instance.user_id = session[:user_id]
    instance.name = params[:vm][:name]
    instance.os = params[:vm][:os]
    instance.cpu = params[:vm][:cpu]
    instance.ram = params[:vm][:ram]
    instance.ip_addr = "192.168.0.#{instance_cnt+1}"
    macs = (1..6).each_with_object([]) do |v, h|
      h << rand(0..255).to_s(16)
    end
    logger.debug macs
    macs.map! do |item|
      item.length == 1 ? "0#{item}" : item;
    end
    instance.mac_addr = macs.join(":")
    logger.debug macs
    instance.save

    redirect_to '/instance/show'
  end

  def show
  	@images = Image.all
  	@image_names = @images.each_with_object({}) do |value, new_hash|
      new_hash[value.id] = value.name
  	end
  	logger.debug @image_names

  	@instances = Instance.where(user_id: session[:user_id]).all
  	logger.debug @instances
  end
end
