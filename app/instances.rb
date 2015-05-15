class Application < Sinatra::Base
  
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
    response = signed_get_request @@API_ROOT+"/badges/#{params[:id_badge_class]}/instances/#{params[:email]}"
    fecha = {
      issuedOn: if response['instance'].nil? then false else response['instance']['issuedOn'] end
    }
    JSON.pretty_generate fecha
  end

  #Retrieve specific badge instance for <email>, <Application> and <Badge Class> (Achievement)
  get '/issuers/:id_app/badges/:id_badge_class/instances/:email' do
    response = signed_get_request @@API_ROOT+"/badges/#{params[:id_badge_class]}/instances/#{params[:email]}"
    fecha = {
      issuedOn: if response['instance'].nil? then false else response['instance']['issuedOn'] end
    }
    JSON.pretty_generate fecha
  
  end  
end