class Application < Sinatra::Base
  
  #List all Cientificos Ciudadanos Applications
  get '/issuers' do
    response = signed_get_request @@API_ROOT+"/issuers"
    JSON.pretty_generate response
  end

  #Create Application
  post '/issuers' do
    body = {
      slug: params['id_app'].downcase,
      name: params['name'],
      url: params['url']
    }
    response = signed_post_request @@API_ROOT+'/issuers', body
    JSON.pretty_generate response
  end
	
end