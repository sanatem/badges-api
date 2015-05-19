require 'bundler'
require 'digest'
require 'uri'

ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir['./models/**/*.rb'].each {|f| require f }

class Application < Sinatra::Base

#Configurations	
  #register Sinatra::ActiveRecordExtension

  configure :production, :development do
    enable :logging
  end

  #Reloader
  configure :development do
    register Sinatra::Reloader
  end
  #Database
  set :database, YAML.load_file('config/database.yml')[ENV['RACK_ENV']]


  @@API_ROOT = "/systems/cientificos_ciudadanos"


#Methods & Helpers
helpers do
    #convierte un json a uri
    def stringify mi_json
      result = []
      mi_json.each do | key, value |
        result << "#{URI.encode(key.to_s)}=#{URI.encode(value.to_s, /(?!\.)\W/)}"
      end
      result.join('&')
    end
    
    def json_status(code, reason)
      status code
      {
        :status => code,
        :reason => reason
      }.to_json
    end

    def jwt_get_signature url

        payload=JWT.encode({ #Payload
          key: "master",
          method: "GET",
          path: url,
        },
        "badgemaster", #Secret
        "HS256", #Algoritmo
        {typ: "JWT", alg:"HS256"} #Headers
        )

    end

    def jwt_post_signature url, body
      body = stringify body
      hash = Digest::SHA256.hexdigest body
      payload=JWT.encode({ #Payload
        key: "master",
        method: "POST",
        path: url,
        body: {
          alg: "sha256",
          hash: hash
        }
      },
      "badgemaster", #Secret
      "HS256", #Algoritmo
      {typ: "JWT", alg:"HS256"} #Headers
      )

    end

    def signed_get_request url
      token=jwt_get_signature url
      HTTParty.get('http://localhost:8080'+url,
        headers:{
          "Authorization"=>"JWT token=\"#{token}\"",
          'Content-Type'=> 'application/x-www-form-urlencoded'
          }
      )
    end

    def signed_post_request url, body
      token = jwt_post_signature url, body
      HTTParty.post('http://localhost:8080'+url,
        {headers:{
          "Authorization"=>"JWT token=\"#{token}\"",
          'Content-Type'=> 'application/x-www-form-urlencoded'
          },
        body: body}
      )
    end
end    

#Setting the content type of the answers
before do
  content_type :json
end

#Endpoints
  
  get '/' do
    JSON.pretty_generate({'Welcome to:'=>'Badges Api'})
  end 

 before '/prueba' do
  content_type :html
 end 
  get '/prueba' do
    File.read('views/prueba.html')
  end

#Error example 404.
  get '/error' do
    json_status 404,"Not found"
  end  

end

require_relative 'badges'
require_relative 'instances'
require_relative 'issuers'