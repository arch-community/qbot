# Initialize the YouTube Search API

REDIRECT_URI = 'http://localhost'.freeze
APPLICATION_NAME = 'AMusicBot'.freeze
CLIENT_SECRETS_PATH = 'yt-client-secret.json'.freeze
CREDENTIALS_PATH = 'yt-credentials.yml'.freeze
SCOPE = Google::Apis::YoutubeV3::AUTH_YOUTUBE_READONLY

def authorize
  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store
  )
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: REDIRECT_URI)
    puts 'Open the following URL in the browser and enter the ' +
         'resulting code after authorization'
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: REDIRECT_URI
    )
  end
  credentials
end

$ytservice = Google::Apis::YoutubeV3::YouTubeService.new
$ytservice.client_options.application_name = APPLICATION_NAME
$ytservice.authorization = authorize

def youtube_search(query)
  results = $ytservice.list_searches(['snippet'], q: query)
  results.items
end

def results_getid(results)
  results[0].id.video_id
end
