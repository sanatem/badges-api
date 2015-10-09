require 'bundler'
require 'digest'
require 'open-uri'

ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym
Encoding.default_internal="utf-8"
Encoding.default_external="utf-8"
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

    #Errores
    def get_error error 
      case error
      when "NotAuthorized"
        error = "Error de encoding (Tildes o caracteres especiales)"
      end
      error
    end 

    #Valida el archivo JSON y devuelve un array de errores
    def validate_json data
      JSON::Validator.fully_validate("schema.json", data)
    end  

end #End de helpers   

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
    request_data = JSON.parse request.body.read
    errors = validate_json(request_data)
    if errors !=[] #Hay errores
      status 409
      JSON.pretty_generate({status:409,reason:"JSON mal formado.",errors:errors})
    else
     #Convierte en Hash al JSON

    @result = {status:"201",reason:"Created",information:"",badges:[]}
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
          @result[:badges] << resp_achievment["badge"]["name"]
          p resp_achievment
        else  
          @result[:status]="500"
          @result[:reason]="No pudieron crearse todas las badges!.Error con badge:"+badge["name"]
          @result[:information]=get_error(resp_achievment["code"])+"."
        end
      } 
     }
     @result[:information]=@result[:information]+"Badges creadas: "+"#{badges_creadas}"
     JSON.pretty_generate(@result)
   end
  end  

  #Metodo de testeo de carga JSON.
  get '/prueba-carga' do
   json_file = File.read("carga.json")
   data_hash = JSON.parse(json_file)
   response = HTTParty.post("http://localhost:9292/carga-json", 
=begin
    :body =>JSON.generate(
        [{
        id_app:"prueba-andando4",
        name:"Galaxy Conqueror",
        url:"https://cientopolis.lifia.info.unlp.edu.ar/galaxy-conqueror",
        badges:[{
                name:"Emperador galáctico",
                imageUrl:"http://example3.com/cat.png",
                criteriaUrl:"http://example.com/catBadge.html",
                description:"T\&eacute;sting!!",
                criteria:[
                          {
                            id: 1, 
                            description: "Criteria description.",
                            required: true,
                            note: "Note about criteria for assessor."
                          }]
                }]
        }]),
=end
    :body => JSON.generate(data_hash),
    :headers => { 'Content-Type' => "application/json;charset=utf-8" } )
    
    response.body

  end

end

require_relative 'badges'
require_relative 'instances'
require_relative 'issuers'

