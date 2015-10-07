require 'bundler'
require 'digest'
require 'open-uri'

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
    #convierte un ruby-hash a formato uri
    def stringify mi_hash
      result = []
      mi_hash.each do | key, value |
        result << "#{URI::encode(key.to_s)}=#{URI::encode(value.to_s)}"
      end
      result=result.join('&')
      result
    end
    
    #Metodo que devuelve status http.
    def json_status(code, reason)
      status code
      {
        :status => code,
        :reason => reason
      }.to_json
    end

    #Firma requerimientos HTTP GET con JWT
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

    #Firma requerimientos HTTP POST con JWT.
    def jwt_post_signature url, body
      #body = stringify body
      sha256 = Digest::SHA256.new
      hash = sha256.hexdigest body     
	    payload=JWT.encode({ #Payload
        key: "master",
        method: "POST",
        path: url,
        body: {
          alg: "sha256",
          hash: hash #adas456
        }
      },
      "badgemaster", #Secret
      "HS256", #Algoritmo
      {typ: "JWT", alg:"HS256"} #Headers
      )

    end

    #Firma requerimientos HTTP GET y lo envia a la api Mozilla.
    def signed_get_request url
      token=jwt_get_signature url
      HTTParty.get('http://localhost:5000'+url,
        headers:{
          "Authorization"=>"JWT token=\"#{token}\"",
          "Content-Type"=> "application/json;charset=utf-8"
          }
      )
    end

    #Firma requerimientos HTTP POST y lo envia a la api Mozilla.
    def signed_post_request url, body
      body_json= body.to_json
      token = jwt_post_signature url, body_json
      HTTParty.post('http://localhost:5000'+url,
        {headers:{
          "Authorization"=>"JWT token=\"#{token}\"",
          "Content-Type"=> "application/json;charset=utf-8",
          },
        body: body_json}
      )

    end

    #Crea un issuer en la API Mozilla.
    def crear_issuer issuer
      body = {
        slug: issuer['id_app'].downcase,
        name: issuer['name'],
        url: issuer['url'] #cientificos-sarasa
      }
      response = signed_post_request @@API_ROOT+'/issuers', body
         
    end

    #Crea una badge (achievement) en la API Mozilla.
    def crear_achievement badge, id_app
      description = badge["description"].encode("UTF-8")
      
      body = {
          name:badge["name"],
          imageUrl:badge["imageUrl"],
          unique: true,
          criteriaUrl: badge["criteriaUrl"],
          earnerDescription: description,
          consumerDescription: description ,
          criteria: badge["criteria"],
          type: 'Badge'
        }
      status 201
      
      response = signed_post_request @@API_ROOT+"/issuers/#{id_app}/badges", body

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
    File.read('views/prueba.html')
  end

#Error example 404.
  get '/error' do
    json_status 404,"Not found"
  end


  #Crea un issuer  y sus badges asociadas en la API Mozilla.
  post '/carga-json' do
    #Traer info del json enviado como parametro.
    request.body.rewind #Vuelve a empezar.
    
    request_data = JSON.parse request.body.read #Content-type: JSON   
    #crear_issuer request_data[0] #PRUEBA
    response = crear_achievement request_data[0]["badges"][0],request_data[0]["id_app"]

    response.to_json

    @result = {status:"201",reason:"Created",information:""}
    #Recorremos los issuers 
    badges_creadas=0
    request_data.each{ |issuer| 
      #creamos /issuers
      resp_issuer = crear_issuer issuer
      #recorremos badges
      
      issuer["badges"].each{ |badge|
        #creamos /issuers/:id_app/badges
        resp_achievment = crear_achievement badge,issuer["id_app"]      
        
        if resp_achievment["status"] == "created"
          badges_creadas=badges_creadas+1
        else  
          p resp_achievment
          @result[:status]="500"
          @result[:reason]="Something went wrong!"
          @result[:information]=resp_achievment["code"]+"."
        end
      } 
     }
     @result[:information]=@result[:information]+"Badges creadas con éxito: "+"#{badges_creadas}"
     @result.to_json
 
  end  

  #Metodo de testeo de carga JSON.
  get '/prueba-carga' do
   response = HTTParty.post("http://localhost:9292/carga-json", 
    :body =>JSON.generate(
        [{
        id_app:"prueba-andando4",
        name:"Galaxy Conqueror",
        url:"https://cientopolis.lifia.info.unlp.edu.ar/galaxy-conqueror",
        badges:[{
                name:"Badge sin criteria",
                imageUrl:"http://example3.com/cat.png",
                criteriaUrl:"http://example.com/catBadge.html",
                description:"T\&eacute;sting!!",
                }]
        }]),
    :headers => { 'Content-Type' => "application/json;charset=utf-8" } )
    
    response.body

  end

end

require_relative 'badges'
require_relative 'instances'
require_relative 'issuers'

