require 'sinatra'
require 'json'
require 'digest'
require 'fileutils'
require 'open-uri'

before do
   headers 'Access-Control-Allow-Origin' => '*', 
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
            'Access-Control-Allow-Headers' => "Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With"
end

set :public_folder, File.dirname(__FILE__)

set :port, 80

get '/file' do
  filename = params['filename'] || 'file'
  send_file File.join(File.dirname(__FILE__), params['name']), :filename => filename;
end

get '/file/gitlab' do
  halt 400 unless params['url']
  url = params['url']
  dir = 'file/gitlab'
  ensure_dir dir
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

post '/notification/:id' do
  body = JSON.dump(JSON.parse(request.body.read))
  dir = "notification/#{params['id']}";
  ensure_dir dir
  file = File.join(dir, Digest::MD5.hexdigest(body));
  open(file, 'wb') do |f|
    f << body
  end
  [200, {'Content-Type' => 'application/json'}, JSON.dump({'message': 'ok'})]
end

get '/notification/:id' do
  dir = "notification/#{params['id']}";
  ensure_dir dir
  result = []
  Dir.glob(dir + "/*") do |file|
    result << JSON.parse(File.new(file).read)
  end
  [200, {'Content-Type' => 'application/json'}, JSON.dump(result)]
end

options '/notification/:id' do
  'ok'
end

get '/materials/:id' do
    result = []
    Dir.glob("material/#{params['id']}/*.json") do |file|
      p file
      result << JSON.parse(File.new(file).read)
    end
    p result
    [200, {'Content-Type' => 'application/json'}, JSON.dump(result)]  
end

post '/upload/material/:id' do
    tempfile = params[:file][:tempfile] 
    filename = params[:file][:filename]

    dir = 'material/' + params['id']
    ensure_dir dir

    hash = Digest::MD5.hexdigest("#{filename}#{Time.now}")
    file = File.join(dir, hash)

    meta = {
      'filename': filename,
      'title': params[:title],
      'time': Time.now.to_s,
      'filepath': file
    }

    File.open(file, 'wb') {|f| f.write tempfile.read }
    File.open(file + '.json', 'w') {|f| f.write JSON.dump(meta)}

    [200, {'Content-Type' => 'application/json'}, JSON.dump({'message': 'ok'})]  
end

def ensure_dir dir
  if (!Dir.exist?(dir))
    FileUtils.mkdir_p(dir)
  end
end