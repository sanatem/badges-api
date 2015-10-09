class Application < Sinatra::Base

    #Create Badge Instance
  post '/badges/:id_badge_class/instances' do
    
    body={
      email: params["email"]
    }
    status 201
    response = signed_post_request @@API_ROOT+"/badges/#{params[:id_badge_class]}/instances", body
    
    fecha={issuedOn:if response['instance'].nil? then nil else response['instance']['issuedOn'] end}

    JSON.pretty_generate fecha  
  end


  #Create <Application> Badge (achievement) Instance
  post '/issuers/:id_app/badges/:id_badge_class/instances' do
    body={
      email: params["email"]
    }
    status 201
    response = signed_post_request @@API_ROOT+"/issuers/#{params[:id_app]}/badges/#{params[:id_badge_class]}/instances", body
    
    fecha={issuedOn:if response['instance'].nil? then nil else response['instance']['issuedOn'] end}

    JSON.pretty_generate fecha

  end

  #List all Cientificos Ciudadanos Badge Instances for <email>
  get '/instances/:email' do
    #============================
    # Problema con este endpoint: Es igual al de abajo.
    #==================
    response = signed_get_request @@API_ROOT+"/instances/#{params[:email]}"    

    instances=[]
    #arreglar para null
    instances=response['instances'].select{|instance| instance["badge"]["issuer"].nil? }
    .map { |instance| {id_badge_class:instance["slug"],name:instance["badge"]["name"]} }
    
    #JSON.pretty_generate({params[:email] => instances})
    JSON.pretty_generate response
  end

  #List all <Appllication> Badge Instances (Achievements) for <email>
  get '/issuers/:id_app/instances/:email' do

    response = signed_get_request @@API_ROOT+"/issuers/#{params[:id_app]}/instances/#{params[:email]}"    

    instances=[]
    if ! response['instances'].nil?
     instances=response['instances'].select{|instance| 
      (! instance["badge"]["issuer"].nil?) and 
      (instance["badge"]["issuer"]["slug"] == "#{params[:id_app]}") }
       .map { |instance| 
          {id_badge_class:instance["slug"],name:instance["badge"]["name"]} }
    end

    JSON.pretty_generate({params[:email] => instances})

  end
  
  #Retrieve specific badge instance for <email> and <Badge Class> 
  get '/badges/:id_badge_class/instances/:email' do
    response = signed_get_request @@API_ROOT+"/badges/#{params[:id_badge_class]}/instances/#{params[:email]}"
    fecha = {
      issuedOn: if response['instance'].nil? then nil else response['instance']['issuedOn'] end
    }
    JSON.pretty_generate fecha
  end

  #Retrieve specific badge instance for <email>, <Application> and <Badge Class> (Achievement)
  get '/issuers/:id_app/badges/:id_badge_class/instances/:email' do
    response = signed_get_request @@API_ROOT+"/badges/#{params[:id_badge_class]}/instances/#{params[:email]}"
    fecha = {
      issuedOn: if response['instance'].nil? then nil else response['instance']['issuedOn'] end
    }
    JSON.pretty_generate fecha
  
  end  
end