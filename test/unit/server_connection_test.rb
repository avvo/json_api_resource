require 'test_helper'

class ServerConnectionTest < MiniTest::Test

  def test_404_returns_empty_set_with_404
    User.stub :where, raise_404! do
      response = PropUserResource.where id: -5
      assert_equal 404, response.meta[:status]

      assert_empty response
    end
  end

  def test_non_404_error_returns_empty_set_with_500
    User.stub :where, raise_client_error! do
      response = PropUserResource.where id: -5
      assert_equal 500, response.meta[:status]

      assert_equal [JsonApiResource::Connections::ServerConnection, JsonApiClient::Errors::ServerError], $error
    end
  end

end