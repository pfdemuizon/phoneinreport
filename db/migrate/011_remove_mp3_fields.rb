class RemoveMp3Fields < ActiveRecord::Migration
  def self.up
    remove_column :reports, :file_wav_url
    remove_column :reports, :file_mp3_url
    remove_column :reports, :length
  end

  def self.down
    add_column :reports, :file_wav_url, :string
    add_column :reports, :file_mp3_url, :string
    add_column :reports, :length, :integer
  end
end
