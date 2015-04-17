require 'test_helper'

class RootTest < AppTest
  def test_get_root
    get '/hello'
    assert_equal 200, last_response.status
    assert_equal 'Hello from sinatra!', last_response.body
  end
end
