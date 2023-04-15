require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'pry'
require 'ethereum.rb'
require 'httparty'

Dir["models/*.rb"].each {|file| require_relative file}

enable :sessions

configure :development do 
  set :database, {adapter: "postgresql", database: "wendigo"}
end


get '/' do   
  erb :index
end


get '/position' do 
  @user = User.first
  copy_list = @user.copy_list || []
  @positions = @user.copied_positions
  @recced_position = @user.recced_position @positions
  erb :position
end


post '/search' do 
  @results = Trader.search params

  erb :trader_results, layout: false
end

post '/user/copy_list/add' do
  @user = User.first
  @user.update copy_list: (@user.copy_list + [params["address"])

  return 200
end


post '/user/copy_list/del' do
  @user = User.first
  list = @user.copy_list
  allos = @user.allocations

  list.each_with_index do |adr, i|
    if adr == params["address"]
      list.delete_at(i)
      allos.delete_at(i)
    end
  end

  @user.update copy_list: list, allocations: allos
  return 200
end

