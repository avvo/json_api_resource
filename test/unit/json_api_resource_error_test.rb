require 'test_helper'

class JsonApiResourceErrorTest < MiniTest::Test


  def test_error_contains_message
    begin 
      UserResource.wraps nil
      UserResource.new
    rescue => e
      assert_equal "UserResource: A resource must have a client class", e.message
    end
  end
end