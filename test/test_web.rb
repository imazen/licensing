require_relative '../web.rb'
require 'minitest/autorun'
require 'rack/test'
require 'dotenv/load'
puts "CHARGEBEE_SITE="
puts ENV['CHARGEBEE_SITE']

class MyAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_authorization_failure
    post '/chargebee'
    assert_equal 403, last_response.status
  end

  def test_authorization_success
    post '/chargebee'
    assert_equal 403, last_response.status
  end

end