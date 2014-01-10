require 'google/api_client'
require 'launchy'

module GoogleDriveAPI
  CLIENT_ID = '341601331933-0ah4hk5ccdarnhbm11jgh7m34rjmokef.apps.googleusercontent.com'
  CLIENT_SECRET = 'ygIEriDiBsL56DFerA-S4qOO1'
  OAUTH_SCOPE = 'https://www.googleapis.com/auth/drive'
  REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'
  BASE_DONE_LETTERS_DIR = "#{ENV['HOME']}/egw-files/done"
  drive = nil
  client = nil

  def self.insert_files
    # folder = get_egw_folder

    Dir.chdir(BASE_DONE_LETTERS_DIR)
    letter_files = Dir.glob("*")

    letter_files.each {|lf|
      # Insert a file
      file = drive.files.insert.request_schema.new({
        'title' => "Subjects.txt",
        'description' => 'Subjects file',
        'mimeType' => 'text/plain'
      })

      media = Google::APIClient::UploadIO.new(lf, 'text/plain')

      result = client.execute(
        :api_method => drive.files.insert,
        :body_object => file,
        :media => media,
        :parameters => {
          'uploadType' => 'multipart',
          'alt' => 'json'
          }
      )
    }
  end

  def self.get_egw_folder
    result = client.execute(
      api_method: drive.files.list,
      parameters: {
        'q' => {
          'title' => 'egw',
          'mimeType' => 'application/vnd.google-apps.folder'
        }
      }
    )

    result
  end

  def self.authorize
    # Create a new API client & load the Google Drive API
    client = Google::APIClient.new
    drive = client.discovered_api('drive', 'v2')

    # Request authorization
    client.authorization.client_id = CLIENT_ID
    client.authorization.client_secret = CLIENT_SECRET
    client.authorization.scope = OAUTH_SCOPE
    client.authorization.redirect_uri = REDIRECT_URI

    uri = client.authorization.authorization_uri
    Launchy.open(uri)

    # Exchange authorization code for access token
    $stdout.write  "Enter authorization code: "
    client.authorization.code = gets.chomp
    client.authorization.fetch_access_token!
  end
end