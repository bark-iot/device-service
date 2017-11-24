require File.expand_path '../spec_helper.rb', __FILE__

describe 'Houses Service' do
  before(:each) do
    DB.execute('TRUNCATE TABLE devices;')
    stub_request(:get, 'http://lb/users/by_token').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 200, body: '{"id":1,"email":"test@test.com","token":"a722658b-0fea-415c-937f-1c1d3c8342fd","created_at":"2017-11-14 16:06:52 +0000","updated_at":"2017-11-14 16:06:52 +0000"}', headers: {})
    stub_request(:get, 'http://lb/users/by_token').
        with(headers: {'Authorization'=>'Bearer wrong_token'}).
        to_return(status: 422, body: '', headers: {})
  end

  it 'should show house for user' do
    header 'Authorization', "Bearer #{token}"
    get "/houses/#{house.id}"

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('MyHouse')
    expect(body['key'] != '').to be_truthy
    expect(body['secret'] == nil).to be_truthy
  end

  it 'should not show house for another user' do
    h = House::Create.(title: 'MyHouse', user_id: 2)['model']
    header 'Authorization', "Bearer #{token}"
    get "/houses/#{h.id}"

    expect(last_response.status).to equal(404)
  end

  it 'should list all houses for user' do
    house_title = house.title
    header 'Authorization', "Bearer #{token}"
    get '/houses'

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body[0]['title'] == house_title).to be_truthy
  end

  it 'should not list houses for another user' do
    House::Create.(title: 'MyHouse', user_id: 2)
    header 'Authorization', "Bearer #{token}"
    get '/houses'

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body.size == 0).to be_truthy
  end

  it 'should not list all houses for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    get '/houses'

    expect(last_response.status).to equal(401)
  end

  it 'should create house for user' do
    header 'Authorization', "Bearer #{token}"
    post '/houses', {title: 'MyHouse', address: 'Baker street 221B'}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('MyHouse')
    expect(body['address']).to eql('Baker street 221B')
    expect(body['key'] != '').to be_truthy
    expect(body['secret'] != '').to be_truthy
  end

  it 'should not create house without title' do
    header 'Authorization', "Bearer #{token}"
    post '/houses', {address: 'Baker street 221B'}

    expect(last_response.status).to equal(422)
    body = JSON.parse(last_response.body)
    expect(body[0] == ['title', ['must be filled']]).to be_truthy
  end

  it 'should not create house for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    post '/houses', {title: 'MyHouse'}

    expect(last_response.status).to equal(401)
  end

  it 'should update house for user' do
    header 'Authorization', "Bearer #{token}"
    put "/houses/#{house.id}", {title: 'My House', address: 'Baker Street 221B'}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('My House')
    expect(body['address']).to eql('Baker Street 221B')
    expect(body['key'] != '').to be_truthy
    expect(body['secret'] == nil).to be_truthy
  end

  it 'should not update house of another user' do
    another_house = House::Create.(title: 'MyHouse', user_id: 2)['model']
    header 'Authorization', "Bearer #{token}"
    put "/houses/#{another_house.id}", {title: 'My House', address: 'Baker Street 221B'}

    expect(last_response.status).to equal(404)
  end

  it 'should not update house without title' do
    header 'Authorization', "Bearer #{token}"
    put "/houses/#{house.id}", {title: '', address: 'Baker street 221B'}

    expect(last_response.status).to equal(422)
    body = JSON.parse(last_response.body)
    expect(body[0] == ['title', ['must be filled']]).to be_truthy
  end

  it 'should not update house for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    put '/houses', {title: 'MyHouse'}

    expect(last_response.status).to equal(401)
  end

  it 'should delete house for user' do
    house_id = house.id
    header 'Authorization', "Bearer #{token}"
    delete "/houses/#{house_id}"

    expect(last_response).to be_ok
    expect(House.where(id: house_id).first == nil).to be_truthy
  end

  it 'should not delete house of another user' do
    another_house = House::Create.(title: 'MyHouse', user_id: 2)['model']
    header 'Authorization', "Bearer #{token}"
    delete "/houses/#{another_house.id}"

    expect(last_response.status).to equal(404)
  end

  it 'should not delete house for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    delete "/houses/#{house.id}"

    expect(last_response.status).to equal(401)
  end

  def token
    'a722658b-0fea-415c-937f-1c1d3c8342fd'
  end

  def house
    House::Create.(title: 'MyHouse', user_id: 1)['model']
  end
end