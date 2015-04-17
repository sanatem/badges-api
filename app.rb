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



end
