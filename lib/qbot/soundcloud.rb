# frozen_string_literal: true

# Initialize the SoundCloud API
module SoundCloud
  @scservice = SoundCloud.new(client_id: 1234)
  def self.soundcloud_search(query); end
end
