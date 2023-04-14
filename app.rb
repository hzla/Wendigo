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

