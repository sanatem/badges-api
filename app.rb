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

  get '/badges' do
    slug="90812gjd"
    name="Joven Cientifico"
    [{id_badge_class:slug,name:name},{id_badge_class:slug,name:"Cientifico Avanzado"}].to_json

  end

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

  post '/badges/:id_badge_class/instances' do

    json_status 200, "ok"

  end

  get '/error' do
    json_status 404,"Not found"
  end


end
