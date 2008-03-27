class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.integer :event_id
      t.integer :campaign_id
      t.string  :city
      t.string  :state
      t.string  :country
      t.float   :latitude
      t.float   :longitude
      t.string  :phone
      t.string  :phone_city
      t.string  :phone_state
      t.string  :file_status
      t.string  :file_wav_url
      t.string  :file_mp3_url 
      t.integer :length
      t.string  :reporter_name
      t.string  :reporter_email
      t.text    :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :reports
  end
end
