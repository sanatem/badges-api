ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require File.expand_path '../../app', __FILE__

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Application
  end
end
