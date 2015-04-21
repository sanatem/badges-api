require 'bundler'

ENV['RACK_ENV'] ||= 'development'
Bundler.require :default, ENV['RACK_ENV'].to_sym

Dir['./models/**/*.rb'].each {|f| require f }

class Application < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure :production, :development do
    enable :logging
  end


#Configurations	
  register Sinatra::ActiveRecordExtension

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
    def json_status(code, reason)
      status code
      {
        :status => code,
        :reason => reason
      }.to_json
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
