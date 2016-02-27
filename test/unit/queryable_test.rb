require 'test_helper'

class QuieriableTest < MiniTest::Test

  def setup
    @resource = UserResource.new({id: 1, name: "Brnadon Sislow"})
  end

  def test_client_can_run_where
    User.stub :where, JsonApiClient::Scope.new(id: 6) do
      User.where.stub :all, JsonApiClient::ResultSet.new([User.new()]) do
        result = UserResource.where id: 6
        refute_empty result
        assert_equal 1, result.count
        assert_equal UserResource, result.first.class
      end
    end
  end

  def test_client_can_run_create
    User.stub_any_instance :save, User.new() do
      result = UserResource.create
      refute_nil result
      assert_equal UserResource, result.class
    end
  end

  def test_client_can_run_find
    User.stub :find, JsonApiClient::ResultSet.new([User.new()]) do
      result = UserResource.find 6
      refute_nil result
      assert_equal UserResource, result.class
    end
  end
end

