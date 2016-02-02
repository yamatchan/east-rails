class ManageController < ApplicationController
  def show
    @instances = Instance.all
    @images = Image.all
    @image_names = @images.each_with_object({}) do |value, new_hash|
      new_hash[value.id] = value.name
    end
    @host_name_arr = Host.all.each_with_object({}) do |value, new_hash|
      new_hash[value.name] = value.id
    end
  end

  def update
    params[:vm][:host_id].each do |instance_id, host_id|
      host_id = host_id.to_i
      instance = Instance.find(instance_id)
      if instance.host_id != host_id then
        # hostの変更
        src_host = Host.find(instance.host_id)
        dst_host = Host.find(host_id)
#        cmd = "ssh root@#{src_host.ip_addr} \"vzmigrate --online #{dst_host.ip_addr} #{instance.id}\""
        Thread.start do
          logger.debug "live migrate #{src_host.ip_addr} => #{dst_host.ip_addr} CID: #{instance.id + 1}"
          VmManager.livemigrate(src_host.ip_addr, dst_host.ip_addr, instance.id + 1)
        end
      end
    end
    redirect_to '/manage/show'
  end
end
