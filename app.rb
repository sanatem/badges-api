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

  get '/prueba' do
    
    #response = signed_post_request '/badges'

    
    description = 'asi me la gane'
    body = {
        name:"Post badge",
        imageUrl:'https://www.dropbox.com/s/nvukekjbuql19jd/badge1.png?dl=1',
        unique: true,
        criteriaUrl: 'info.unlp.edu.ar',
        earnerDescription: description,
        consumerDescription: description,
        type: 'Badge'
      }
    
    response = signed_post_request "/systems/badgekit/badges", body
    JSON.pretty_generate response
  end


  #BADGE CLASSES ENDPOINTS

  #List all Cientificos Ciudadanos Badge Classes. 
  get '/badges' do
    slug="90812gjd"
    name="Joven Cientifico"    
    [{id_badge_class:slug,name:name},{id_badge_class:slug,name:"Cientifico Avanzado"}].to_json

  end

  #List all <Application> Badge Classes (achievements).
  get '/issuers/:id_app/badges' do
    status 200

    [
      {
          id_badge_class: "h1k2bfhg",
          name: "Asesino de aliens"
      },
      {
          id_badge_class: "2gd1d2w3g",
          name: "Sherlock Holmes Espacial"
      },
      {
          id_badge_class: "2134gdsa8",
          name: "Stephen Hawking"
      }
    ].to_json
  end

  #Create Badge Class
  post '/badges' do
=begin
name: Name of the badge. Maximum 255 characters.
image OR imageUrl: Image for the program. Should be either multipart data or a URL.
criteriaUrl: Link to badge criteria webpage.
description: Description of the badge.
=end
    status 201
    {id_badge_class:"2gd1d2w3g"}.to_json
  
  end

  #BADGE INSTANCES ENDPOINTS

  #Create Badge Instance
  post '/badges/:id_badge_class/instances' do
     status 201
    {issuedOn:"2015-04-21"}.to_json

  end


  #Create <Application> Badge (achievement) Instance
  post '/issuers/:id_app/badges/:id_badge_class/instances' do
    status 201
    {issuedOn:"2015-04-17"}.to_json

  end

  #List all Cientificos Ciudadanos Badge Instances for <email>
  get '/instances/:email' do
    JSON.pretty_generate({params[:email] => [
      {
          id_badge_class: "h1k2bfhg",
          name: "Joven Cientifico"
      },
      {
          id_badge_class: "2gd1d2w3g",
          name: "Cientifico Avanzado"
      },
      {
          id_badge_class: "2134gdsa8",
          name: "Arquimedes"
      }
    ]})
  end

  #List all <Application> Badge Instances (Achievements) for <email>
  get '/issuers/:id_app/instances/:email' do

    JSON.pretty_generate({params[:email] => [
      {
          id_badge_class: "h1k2bfhg",
          name: "Asesino de aliens"
      },
      {
          id_badge_class: "2gd1d2w3g",
          name: "Sherlock Holmes Espacial"
      },
      {
          id_badge_class: "2134gdsa8",
          name: "Stephen Hawking"
      }
    ]})
  end
  
  #Retrieve specific badge instance for <email> and <Badge Class> 
  get '/badges/:id_badge_class/instances/:email' do
    
    {issuedOn: "2009-09-25"}.to_json

  end

  #Retrieve specific badge instance for <email>, <Application> and <Badge Class> (Achievement)
  get '/issuers/:id_app/badges/:id_badge_class/instances/:email' do

    params[:email]=="error" ? ({ issuedOn: nil }.to_json) : ({issuedOn: "2015-03-05"}.to_json)   
  
  end  
  

  #Error example 404.
  get '/error' do
    json_status 404,"Not found"
  end  

end
