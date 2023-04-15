require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'pry'

Dir["models/*.rb"].each {|file| require_relative file}

configure :development do 
  set :database, {adapter: "postgresql", database: "wendigo"}
end


get '/' do 

  
  erb :index
end

post '/search' do 
  p params

  @results = Trader.search params

  erb :trader_results, layout: false
end


get '/set_user/:id'

end

