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

  @positions = []

  gmx_client = Gmx.new

  copy_list.each do |adr|
    @positions << gmx_client.positions(adr)
  end

  p @positions

  erb :position
end


post '/search' do 
  p params

  @results = Trader.search params

  erb :trader_results, layout: false
end


get '/set_user/:id' do

end

