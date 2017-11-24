require 'rest-client'

before do
  unless request.path_info.include? '/docs'
    authorization_header = request.env['HTTP_AUTHORIZATION'].to_s
    begin
      response = RestClient.get('http://lb/users/by_token', headers={'Authorization' => authorization_header})
    rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::UnprocessableEntity => err
      LOGGER.info "Unable to authorize user with header #{authorization_header}"
      halt 401
    else
      USER = JSON.parse(response.body)
      LOGGER.info "Authorized user #{response.body}"
    end
  end
end