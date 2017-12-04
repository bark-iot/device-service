require File.expand_path '../spec_helper.rb', __FILE__

describe 'Devices Service' do
  before(:each) do
    DB.execute('TRUNCATE TABLE devices;')
    stub_request(:get, 'http://lb/users/by_token').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 200, body: '{"id":1,"email":"test@test.com","token":"a722658b-0fea-415c-937f-1c1d3c8342fd","created_at":"2017-11-14 16:06:52 +0000","updated_at":"2017-11-14 16:06:52 +0000"}', headers: {})
    stub_request(:get, 'http://lb/users/by_token').
        with(headers: {'Authorization'=>'Bearer wrong_token'}).
        to_return(status: 422, body: '', headers: {})
    stub_request(:get, 'http://lb/houses/1').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 200, body: '{"id":1,"user_id":1,"title":"Test","address":"Pr Pobedi 53b","key":"4d27328d-cbf6-493e-a5ec-7f6848ece614","created_at":"2017-11-24 20:32:29 +0000","updated_at":"2017-11-24 20:32:29 +0000"}', headers: {})
    stub_request(:get, 'http://lb/houses/2').
        with(headers: {'Authorization'=>'Bearer wrong_token'}).
        to_return(status: 200, body: '{"id":1,"user_id":2,"title":"Test","address":"Pr Pobedi 53b","key":"4d27328d-cbf6-493e-a5ec-7f6848ece614","created_at":"2017-11-24 20:32:29 +0000","updated_at":"2017-11-24 20:32:29 +0000"}', headers: {})
    stub_request(:get, 'http://lb/houses/3').
        with(headers: {'Authorization'=>'Bearer wrong_token'}).
        to_return(status: 404, body: '', headers: {})
  end

  it 'should show device for house' do
    header 'Authorization', "Bearer #{token}"
    get "/houses/1/devices/#{device.id}"

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('MyDevice')
    expect(body['token'] != '').to be_truthy
  end

  it 'should not show device for another house' do
    d = Device::Create.(title: 'MyDevice', house_id: 2)['model']
    header 'Authorization', "Bearer #{token}"
    get "/houses/1/devices/#{d.id}"

    expect(last_response.status).to equal(404)
  end

  it 'should list all devices for house' do
    device_title = device.title
    header 'Authorization', "Bearer #{token}"
    get 'houses/1/devices'

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body[0]['title'] == device_title).to be_truthy
  end

  it 'should not list devices for another house' do
    Device::Create.(title: 'MyDevice', house_id: 2)
    header 'Authorization', "Bearer #{token}"
    get '/houses/1/devices'

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body.size == 0).to be_truthy
  end

  it 'should not list all devices for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    get '/houses/1/devices'

    expect(last_response.status).to equal(401)
  end

  it 'should create device for user' do
    header 'Authorization', "Bearer #{token}"
    post '/houses/1/devices', {title: 'MyDevice', com_type: 1}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('MyDevice')
    expect(body['com_type']).to eql(1)
    expect(body['token'] != '').to be_truthy
  end

  it 'should not create device without title' do
    header 'Authorization', "Bearer #{token}"
    post '/houses/1/devices', {com_type: 1}

    expect(last_response.status).to equal(422)
    body = JSON.parse(last_response.body)
    expect(body[0] == ['title', ['must be filled']]).to be_truthy
  end

  it 'should not create device for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    post '/houses/1/devices', {title: 'MyDevice'}

    expect(last_response.status).to equal(401)
  end

  it 'should update device for user' do
    header 'Authorization', "Bearer #{token}"
    put "/houses/1/devices/#{device.id}", {title: 'My Device'}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('My Device')
  end

  it 'should not update device of another house' do
    another_device = Device::Create.(title: 'MyDevice', house_id: 2)['model']
    header 'Authorization', "Bearer #{token}"
    put "/houses/1/devices/#{another_device.id}", {title: 'My Device'}

    expect(last_response.status).to equal(404)
  end

  it 'should not update device without title' do
    header 'Authorization', "Bearer #{token}"
    put "/houses/1/devices/#{device.id}", {title: '', com_type: 1}

    expect(last_response.status).to equal(422)
    body = JSON.parse(last_response.body)
    expect(body[0] == ['title', ['must be filled']]).to be_truthy
  end

  it 'should not update device for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    put "/houses/1/devices/#{device.id}", {title: 'MyDevice'}

    expect(last_response.status).to equal(401)
  end

  it 'should approve device for house' do
    header 'Authorization', "Bearer #{token}"
    post "/houses/1/devices/#{device.id}/approved", {approved: true}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('MyDevice')
    expect(body['approved_at'] != nil).to be_truthy
  end

  it 'should disapprove device for house' do
    header 'Authorization', "Bearer #{token}"
    post "/houses/1/devices/#{device.id}/approved", {approved: false}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('MyDevice')
    expect(body['approved_at'] == nil).to be_truthy
  end

  it 'should delete device for house' do
    device_id = device.id
    header 'Authorization', "Bearer #{token}"
    delete "/houses/1/devices/#{device_id}"

    expect(last_response).to be_ok
    expect(Device.where(id: device_id).first == nil).to be_truthy
  end

  it 'should not delete device of another house' do
    another_device = Device::Create.(title: 'MyDevice', house_id: 2)['model']
    header 'Authorization', "Bearer #{token}"
    delete "/houses/1/devices/#{another_device.id}"

    expect(last_response.status).to equal(404)
  end

  it 'should not delete device for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    delete "/houses/1/devices/#{device.id}"

    expect(last_response.status).to equal(401)
  end

  def token
    'a722658b-0fea-415c-937f-1c1d3c8342fd'
  end

  def device
    Device::Create.(title: 'MyDevice', house_id: 1, com_type: 0)['model']
  end
end