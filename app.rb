require 'sinatra'
require 'net/http'
require 'nokogiri'

get '/' do
  "Request a git object id."
end

options '/:object_id' do
  response.headers["Access-Control-Allow-Origin"] = "*"
  response.headers["Access-Control-Allow-Methods"] = "GET"
  response.headers["Access-Control-Allow-Headers"] = "X-Prototype-Version,X-CSRF-Token,X-Requested-With"

  halt 200
end

get '/:object_id' do
  if params[:object_id] =~ /^[a-fA-F0-9]{40}$/
    exists = `git --git-dir=/Users/ryan/source/dc3/idp.data/.git --work-tree=/Users/ryan/source/dc3/idp.data cat-file -e #{params[:object_id]}`
    if $?.to_i == 0
      xml = `git --git-dir=/Users/ryan/source/dc3/idp.data/.git --work-tree=/Users/ryan/source/dc3/idp.data show #{params[:object_id]}`
      edition=Nokogiri::XML(xml).xpath("//tei:div[@type='edition']",'tei'=>'http://www.tei-c.org/ns/1.0').first.to_s
      uri = URI.parse('http://localhost:9999/')
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new('/')
      request.set_form_data({'type' => 'epidoc', 'direction' => 'xml2nonxml', 'content' => edition})

      cache_control :public, :max_age => 31536000
      response.headers["Vary"] = "Accept-Encoding"
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["X-XSS-Protection"] = "0"
      response.headers["Content-Type"] = "application/json"

      return http.request(request).body
    else
      halt 404
    end
  else
    halt 400
  end
end
