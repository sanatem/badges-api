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
  #set :database, YAML.load_file('config/database.yml')[ENV['RACK_ENV']]


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
      HTTParty.get('http://localhost:5000'+url,
        headers:{
          "Authorization"=>"JWT token=\"#{token}\"",
          'Content-Type'=> 'application/x-www-form-urlencoded'
          }
      )
    end

    def signed_post_request url, body
      token = jwt_post_signature url, body
      HTTParty.post('http://localhost:5000'+url,
        {headers:{
          "Authorization"=>"JWT token=\"#{token}\"",
          'Content-Type'=> 'application/x-www-form-urlencoded'
          },
        body: body}
      )
    end

    def crear_issuer issuer
      body = {
        slug: issuer['id_app'].downcase,
        name: issuer['name'],
        url: issuer['url']
      }
      response = signed_post_request @@API_ROOT+'/issuers', body
      puts JSON.pretty_generate response    
    end

    def crear_achievement badge, id_app
      description = badge["description"]
      body = {
          name:badge["name"],
          imageUrl:badge["imageUrl"],
          unique: true,
          criteriaUrl: badge["criteriaUrl"],
          earnerDescription: description,
          consumerDescription: description ,
          type: 'Badge'
        }
      status 201
      
      response = signed_post_request @@API_ROOT+"/issuers/#{id_app}/badges", body
      puts JSON.pretty_generate response  
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

  post '/carga-json' do
    #Traer info del json enviado como parametro.
    request.body.rewind #Vuelve a empezar.
    
    request_data = JSON.parse request.body.read #Content-type: JSON   
    #Recorremos los issuers
    request_data.each{ |issuer| 
      #creamos /issuers
      crear_issuer issuer
      #recorremos badges
      issuer["badges"].each{ |badge|
        #creamos /issuers/:id_app/badges
        crear_achievement badge,issuer["id_app"]
      } 
     }
     #request_data.to_json
     {recibimos:ok}.to_json
  end  
  

  get '/prueba-carga' do
   response = HTTParty.post("http://163.10.5.42:9292/carga-json", 
    :body =>
        [{
        id_app:"nueva_badge",
        name:"Nueva badge",
        url:"http://example2.com",
        badges:[{
                name:"BADGE DE PRUEBA",
                imageUrl:"http://example2.com/cat.png",
                criteriaUrl:"http://example.com/catBadge.html",
                description:"You love cats"#Ojo con los "!!""
                }]
        }].to_json,
    :headers => { 'Content-Type' => 'application/json' } )
    
    response.body   

  end

end

require_relative 'badges'
require_relative 'instances'
require_relative 'issuers'

