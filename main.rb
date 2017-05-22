require 'sinatra'
require 'json'
require 'digest'
require 'fileutils'
require 'open-uri'

before do
   headers 'Access-Control-Allow-Origin' => '*', 
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']  
end

set :public_folder, File.dirname(__FILE__)
get '/menu' do
  halt 400 unless params['course']
  name = params['course']
  mock = {
    'project': ['Project 1', 'Project 2'],
    'lab': []
  }
  [200, {'Content-Type' => 'application/json'}, JSON.dump(mock)]
  # JSON.dump(mock)
end

get '/file' do
  send_file File.join(File.dirname(__FILE__), params['name']);
end

get '/file/gitlab' do
  halt 400 unless params['url']
  url = params['url']
  dir = 'file/gitlab'
  if (!Dir.exist?(dir))
    FileUtils.mkdir_p(dir)
  end
  file = File.join(dir, Digest::MD5.hexdigest(url))
  if (File.exist?(file)) 
    send_file file
  end
  data = open(url).read
  open(file, 'wb') do |f|
    f << data
  end
  send_file file
end
