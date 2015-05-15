class Application < Sinatra::Base
  
  #Create Badge Instance
  post '/badges/:id_badge_class/instances' do
    
    body={
      email: params["email"]
    }
    status 201
    response = signed_post_request @@API_ROOT+"/badges/#{params[:id_badge_class]}/instances", body
    
    fecha={issuedOn:response['instance']['issuedOn']}

    JSON.pretty_generate fecha
  end


  #Create <Application> Badge (achievement) Instance
  post '/issuers/:id_app/badges/:id_badge_class/instances' do
    body={
      email: params["email"]
    }
    status 201
    response = signed_post_request @@API_ROOT+"/issuers/#{params[:id_app]}/badges/#{params[:id_badge_class]}/instances", body
    
    fecha={issuedOn:response['instance']['issuedOn']}

    JSON.pretty_generate fecha

  end

  #List all Cientificos Ciudadanos Badge Instances for <email>
  get '/instances/:email' do
    
    response = signed_get_request @@API_ROOT+"/instances/#{params[:email]}"    

    instances=[]
    response['instances'].map { |instance| {id_badge_class:instance["slug"],name:instance["badge"]["slug"]} }
    #JSON.pretty_generate({params[:email] => instances})
    
    JSON.pretty_generate response
    
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