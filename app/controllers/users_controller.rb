require 'rubygems'
require 'json'
require 'digest/md5'

class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:show]

  def new
    @user = User.new
  end

  def show
    @user = current_user
    @md5 = digest = Digest::MD5.hexdigest(@user.email)[0...11]
  end

  def create
    @user = User.new(params[:user])
    @user.memcached = create_memcached_instance
    if @user.save
      sign_in @user
      flash[:success] = "Welcome!"
      redirect_to me_path
    else
      render 'new'
    end
  end
  
  private

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def create_memcached_instance
    docker_path = '/home/julien/docker-master/'
    container_id = `#{docker_path}docker run -d -p 11211 jbarbier/memcached memcached -u daemon`
    cmd = "#{docker_path}docker inspect #{container_id}"
    json_infos = `#{cmd}`
    i = JSON.parse(json_infos)
    port = i["NetworkSettings"]["PortMapping"]["11211"]
  end

end
