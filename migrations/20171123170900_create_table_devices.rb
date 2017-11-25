class CreateTableDevices < Sequel::Migration
  def up
    create_table :devices do
      primary_key :id
      column :house_id, Integer
      column :title, String
      column :token, String
      column :com_type, Integer # communication type (0 - rest api, 1 - tcp)
      column :online, :boolean
      column :approved_at, :timestamp
      column :created_at, :timestamp
      column :updated_at, :timestamp
    end
  end

  def down
    drop_table :devices
  end
end