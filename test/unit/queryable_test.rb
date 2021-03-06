require 'test_helper'

class QueryableTest < MiniTest::Test

  def test_has_connection
    refute_equal 0, PropUserResource._connections.count
  end

  def test_connection_client_is_the_resource_client
    refute_equal 0, PropUserResource._connections.count
    assert_equal User, PropUserResource._connections.first.client
  end

  def test_client_can_run_where
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, JsonApiClient::ResultSet.new([User.new()]) do
        result = PropUserResource.where id: 6
        refute_empty result
        assert_equal 1, result.count
        assert_equal PropUserResource, result.first.class
      end
    end
  end

  def test_class_client_calls_perserve_meta
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, JsonApiClient::ResultSet.new([User.new()]) do
        result = PropUserResource.where id: 6
        assert_equal JsonApiClient::ResultSet, result.class
      end
    end
  end


  def test_client_can_run_find
    User.stub :find, JsonApiClient::ResultSet.new([User.new()]) do
      result = PropUserResource.find 6
      refute_nil result
      assert_equal PropUserResource, result.class
    end
  end

  def test_client_can_handle_404_in_find
    User.stub :find, JsonApiClient::ResultSet.new() do
      refute PropUserResource.find 6
    end
  end

  def test_client_errors_are_propagated_up_on_class_level_client_call
    User.stub :where, raise_client_error! do
      assert_raises JsonApiResource::Errors::UnsuccessfulRequest do
        response = PropUserResource.where id: -5
      end
    end
  end
end

