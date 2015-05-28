require 'sinatra'
require 'rack-flash'
require 'json'
require 'pry'
require 'tilt/erb'
require 'dotenv'
require 'tilt/sass'
require 'bootstrap-sass'
require 'compass'
require 'omniauth'
require 'omniauth-foursquare'
require 'keen'

Dotenv.load! unless ENV['RACK_ENV'] == 'production'

require File.expand_path('../models/drink.rb', __FILE__)
require File.expand_path('../models/consumption.rb', __FILE__)

module Coffee
  class App < Sinatra::Base
    use Rack::Session::Cookie
    use Rack::Flash
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
      if current_user
        @drinks = Drink.all
        erb :index
      else
        erb :logged_out
      end
    end

    get '/analytics' do
      authenticate
      erb :analytics
    end

    get '/auth/foursquare/callback' do
      redirect '/' unless auth_hash['uid'] == ENV['ALLOWED_UID']

      session['current_user'] = {
        info: auth_hash['info'],
        uid: auth_hash['uid'],
        token: auth_hash['credentials']['token']
      }.to_json

      flash[:notice] = "Welcome back, #{auth_hash['info']['name']}."

      redirect '/'
    end

    get '/sign_out' do
      session['current_user'] = nil
      flash[:notice] = 'You are logged out.'
      redirect '/'
    end

    post '/log' do
      authenticate
      drink = Drink.new(params['name'], params['size'])
      consumption = Consumption.new(drink)
      consumption.save
      flash[:notice] = 'Saved!'

      redirect '/'
    end

    def authenticate
      if current_user.nil?
        flash[:notice] = 'You must log in first.'
        redirect '/'
      end
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
