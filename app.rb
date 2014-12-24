require 'sinatra'
require 'json'
require 'haml'

require './lib/asaedit'

# Load Config, be sure to edit as needed!
CONFIG = JSON.parse(File.read('./config/config.json'))

get '/home' do
  redirect '/'
end

get '/' do
  @title = 'asaedit'
  haml :home
end

post '/make_user' do
  begin
    user = make_user(@params[:user])
    user.to_json
  rescue Exception => e
    status 400
    body e.inspect.to_s
  end
end

get '/users' do
  begin
    resp = users
    resp.to_json
  rescue Exception => e
    status 400
    body e.inspect.to_s
  end
end
