class Application < Sinatra::Base

  #List all Cientificos Ciudadanos Badge Classes. 
  get '/badges' do
    response = signed_get_request @@API_ROOT+"/badges"
    badges = []
    if ! response["badges"].nil?
      response["badges"].each do
        |each|
        badges << {id_badge_class:each["slug"], name:each["name"]} 
      end 
    end
    JSON.pretty_generate badges
  end

  #List all <Application> Badge Classes (achievements).
  get '/issuers/:id_app/badges' do
    status 200
    response = signed_get_request @@API_ROOT+"/issuers/#{params[:id_app]}/badges"
    badges = []
    if ! response["badges"].nil?
      response["badges"].each do |each| 
        badges << {id_badge_class:each["slug"], name:each["name"]}
      end     
    end
  
    JSON.pretty_generate badges
  end

  #Create Badge Class
  post '/badges' do
    #'https://www.dropbox.com/s/nvukekjbuql19jd/badge1.png?dl=1'     
    description = params["description"]
    body = {
        name:params["name"],
        imageUrl:params["imageUrl"],
        unique: true,
        criteriaUrl: params["criteriaUrl"],
        earnerDescription: description,
        consumerDescription: description ,
        type: 'Badge'
      }
    status 201
    
    response = signed_post_request @@API_ROOT+"/badges", body
    JSON.pretty_generate response
  end

  #Create Achievement Badge Class
  post '/issuers/:id_app/badges' do
    #'https://www.dropbox.com/s/nvukekjbuql19jd/badge1.png?dl=1'     
    description = params["description"]
    body = {
        name:params["name"],
        imageUrl:params["imageUrl"],
        unique: true,
        criteriaUrl: params["criteriaUrl"],
        earnerDescription: description,
        consumerDescription: description ,
        type: 'Badge'
      }
    status 201
    
    response = signed_post_request @@API_ROOT+"/issuers/#{params[:id_app]}/badges", body
    JSON.pretty_generate response
  end
end