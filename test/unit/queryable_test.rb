require 'test_helper'

class QuieriableTest < MiniTest::Test

  def setup
    @resource = UserResource.new({id: 1, name: "Brnadon Sislow"})
  end

  def test_client_can_run_where
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, JsonApiResource::ResultSet.new([User.new()]) do
        result = UserResource.where id: 6
        refute_empty result
        assert_equal 1, result.count
        assert_equal UserResource, result.first.class
      end
    end
  end

  def test_class_client_calls_perserve_meta
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, JsonApiResource::ResultSet.new([User.new()]) do
        result = UserResource.where id: 6
        assert_equal JsonApiResource::ResultSet, result.class
      end
    end
  end


  def test_client_can_run_find
    User.stub :find, JsonApiResource::ResultSet.new([User.new()]) do
      result = UserResource.find 6
      refute_nil result
      assert_equal UserResource, result.class
    end
  end

  def test_client_errors_are_handled_on_class_level_client_call
    User.stub :find, raise_client_error! do
      response = UserResource.where id: -5
      assert_equal( { ServerError: ["Internal server error at: http://localhost:3000/api/1"] }, response.errors.messages )
    end
  end
end

