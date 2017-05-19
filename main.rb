require 'sinatra'
require 'json'

get '/' do
  halt 400 unless params['name']
  name = params['name']
  JSON.dump({'name': "Hello, #{name}"})
end