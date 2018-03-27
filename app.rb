require 'base64'
require 'tokens'
require 'bcrypt'
require 'securerandom'
require 'rack/ssl'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'sinatra'
require 'pry'
require_relative 'config'
enable :sessions

set :server, 'webrick'
set :server_settings, @webrick_options

@tokens = Tokens.new

def valid_key?(key)
  if not defined? @valid_key 
    key_s = File.read('authorized_keys').chomp
    @valid_key = BCrypt::Password.new(key_s) 
  end
  is_valid = @valid_key ==key
  return is_valid
end

def generate_new_key
  key_s = File.read('allowed_keys').chomp
  key = BCrypt::Password.create(key_s)
  File.write('authorized_keys', key)
end

before do
  pass if request.path_info == "/login"
  @token = session[:token]
  error 401 unless token.valid?(@token)
end



get '/login' do
 key = params[:key]

 if valid_key? key
  token = @tokens.create
  session[:token] = token
 else
  error 401
 end
end 

get '/' do
  %Q{
    <html>
      <body>
        Hello: <br/>
        Token: #{@token}
      </body>
    </html>
    }
end

