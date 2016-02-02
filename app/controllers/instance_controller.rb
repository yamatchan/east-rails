require 'ipaddr'

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
    host_id = 2
#    instance_cnt = 100 + Instance.where(user_id: session[:user_id], host_id: host_id).count

    instance_cnt = 100 + Instance.count
    host = Host.where(id: host_id).first
    instance_base_ip_addr = "169.254.128.100"
    mask_len = 20
    ip_addr = IPAddr.new("#{instance_base_ip_addr}").mask(mask_len) | instance_cnt
    logger.debug ip_addr

    instance = Instance.new
    logger.debug instance
    instance.user_id = session[:user_id]
    instance.host_id = host_id
    instance.name = params[:vm][:name]
    instance.os = params[:vm][:os]
    instance.cpu = params[:vm][:cpu]
    instance.ram = params[:vm][:ram]
    instance.storage = params[:vm][:storage]
#    instance.ip_addr = "192.168.0.#{instance_cnt+1}"
    instance.ip_addr = ip_addr.to_s
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

    Thread.start do
      logger.debug "#{host.ip_addr}, #{instance.id}, #{ip_addr.to_s}"
      VmManager.new(host.ip_addr, instance.id + 1, ip_addr.to_s, "debian-7.0-x86", "vswap-256m", params[:vm][:name], params[:vm][:cpu], params[:vm][:ram], params[:vm][:storage])
    end

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
