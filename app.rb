require 'sinatra'
require 'net/http'
require 'nokogiri'

get '/' do
  "Request a git object id."
end

get '/:object_id' do
  xml=`git --git-dir=/Users/ryan/source/dc3/idp.data/.git --work-tree=/Users/ryan/source/dc3/idp.data show #{params[:object_id]}`
  edition=Nokogiri::XML(xml).xpath("//tei:div[@type='edition']",'tei'=>'http://www.tei-c.org/ns/1.0').first.to_s
  uri = URI.parse('http://localhost:9999/')
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new('/')
  request.set_form_data({'type' => 'epidoc', 'direction' => 'xml2nonxml', 'content' => edition})

  cache_control :public, :max_age => 31536000
  response.headers["Vary"] = "Accept-Encoding"

  return http.request(request).body
end
