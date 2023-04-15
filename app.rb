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

before do
  session[:user_id] = 1
  @user = User.find session[:user_id]
end

########## POSITIONS ###################

get '/' do   
  erb :index
end


get '/position' do 
  # @user = User.first
  copy_list = @user.copy_list || []
  @positions = @user.copied_positions
  @recced_position = @user.recced_position @positions
  erb :position
end


post '/search' do 
  @results = Trader.search params

  erb :trader_results, layout: false
end

######### USER UPDATES ################ 

post '/user/copy_list/add' do
  @user.update(copy_list: (@user.copy_list + [params["adr"]]), allocations: (@user.allocations + [0]))
  return 200
end

post '/user/allocations' do
  allo = @user.allocations

  allo[params["index"].to_i] = params["allo"].to_i
  @user.update allocations: allo
  return 200
end

post '/user/sizing' do
  @user.update max_trade_size: params["sizing"].to_i
  return 200
end

post '/user/copy_list/del' do
  list = @user.copy_list
  allos = @user.allocations

  idx = params["index"].to_i

  list.delete_at(idx)
  allos.delete_at(idx)

  @user.update copy_list: list, allocations: allos
  return 200
end

######### UNISWAP ################ 



get '/uni_tools' do 


  erb :uni_tools
end

post '/avg_cb' do 
  p params
  result = Uniswap.get_balance_weighted_avg_cost_basis params["adr"], params["token"], [params["lb"].to_f, params["ub"].to_f]

  @lb = params["lb"].to_f
  @ub = params["ub"].to_f
  @cb = result[:cb]
  @accounts = result[:accounts]
  
  erb :cost_basis, layout: false

end






