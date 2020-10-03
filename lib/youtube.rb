# frozen_string_literal: true

# Code for interaction with YT's API
module YouTube
  # Initialize the YouTube Search API

  @redirect_uri = 'http://localhost'
  @application_name = 'AMusicBot'
  @client_secrets_path = 'yt-client-secret.json'
  @credentials_path = 'yt-credentials.yml'
  @scope = Google::Apis::YoutubeV3::AUTH_YOUTUBE_READONLY

  class << self; attr_accessor :service; end

  # rubocop: disable Metrics/MethodLength
  def self.authorize
    client_id = Google::Auth::ClientId.from_file(@client_secrets_path)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: @credentials_path)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, @scope, token_store
    )
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: @redirect_uri)
      puts 'Open the following URL in the browser and enter the ' \
           'resulting code after authorization'
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: @redirect_uri
      )
    end
    credentials
  end
  # rubocop: enable Metrics/MethodLength

  def self.init
    @service = Google::Apis::YoutubeV3::YouTubeService.new
    @service.client_options.application_name = @application_name
    @service.authorization = authorize
  end

  def self.search(query)
    results = @service.list_searches(['snippet'], q: query)
    results.items
  end

  def self.results_getid(results)
    results[0].id.video_id
  end
end
