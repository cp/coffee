require 'sinatra'
require 'pry'
require 'tilt/erb'
require 'dotenv'
require 'tilt/sass'
require 'bootstrap-sass'
require 'compass'
require 'omniauth'
require 'omniauth-foursquare'

Dotenv.load! unless ENV['RACK_ENV'] == 'production'

module Coffee
  class App < Sinatra::Base
    use Rack::Session::Cookie
    use OmniAuth::Builder do
      provider :foursquare, ENV['FOURSQUARE_CLIENT_ID'], ENV['FOURSQUARE_CLIENT_SECRET']
    end

    configure do
      Compass.configuration do |config|
        config.project_path = File.dirname(__FILE__)
      end

      set :scss, Compass.sass_engine_options
    end

    get '/styles.css' do
      scss :"sass/styles"
    end

    get '/' do
      erb :index
    end

    get '/auth/foursquare/callback' do
      redirect '/' unless auth_hash['uid'] == ENV['ALLOWED_UID']

      session['current_user'] = {
        info: auth_hash['info'],
        uid: auth_hash['uid'],
        token: auth_hash['credentials']['token']
      }.to_json

      redirect '/'
    end

    get '/sign_out' do
      session['current_user'] = nil
      redirect '/'
    end

    post '/log' do
      p params
      erb :index
    end

    def current_user
      return nil unless session['current_user']
      JSON.parse(session['current_user'])
    end

    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
