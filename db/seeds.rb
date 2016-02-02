# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

@user = User.new
@user.id_str = "demo"
@user.password = "demo"
@user.save

@user = User.new
@user.id_str = "hoge"
@user.password = "hoge"
@user.save

@image = Image.new
@image.name = "devian-7.0-x86"
@image.save

@image = Image.new
@image.name = "centos-6.5-x86"
@image.save

@host = Host.new
@host.ip_addr = "169.254.16.11"
@host.netmask_len = 20
@host.ram = 2048
@host.storage = 128
@host.name = "kojima-host"
@host.cpunodes = 500000
@host.save

@host = Host.new
@host.ip_addr = "169.254.32.11"
@host.netmask_len = 20
@host.ram = 2048
@host.storage = 128
@host.name = "yamada-host"
@host.cpunodes = 500000
@host.save

