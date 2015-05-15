class Application < Sinatra::Base

  #List all Cientificos Ciudadanos Badge Classes. 
  get '/badges' do
    slug="90812gjd"
    name="Joven Cientifico"    
    [{id_badge_class:slug,name:name},{id_badge_class:slug,name:"Cientifico Avanzado"}].to_json

    response = signed_get_request @@API_ROOT+"/badges"
    badges = []
    response["badges"].each do
      |each|
      badges << {id_badge_class:each["slug"], name:each["name"]}
    end
    JSON.pretty_generate badges
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

    response = signed_get_request @@API_ROOT+"/#{params[:id_app]}/badges"
    badges = []
    # response["badges"].each do
    #   |each|
    #   badges << {id_badge_class:each["slug"], name:each["name"]}
    # end
    JSON.pretty_generate response
  end

  #Create Badge Class
  post '/badges' do
    #{id_badge_class:"2gd1d2w3g"}.to_json
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
    
    response = signed_post_request "/systems/badgekit/badges", body
    JSON.pretty_generate response
  end
end