require 'test_helper'

class ResourceTest < MiniTest::Test
  def setup
    @resource = UserResource.new
  end

  def test_new_resource_isnt_persisted
    assert @resource.new_record?
    refute @resource.persisted?
  end

  def test_resource_with_id_is_persisted
    @resource.id = 1
    assert @resource.persisted?
    refute @resource.new_record?
  end

  def test_save_runs_callbacks
    @resource.client.stub :save, User.new({}) do
      assert_empty @resource.errors.messages
      
      @resource.client.stub :errors, {id: "something something"} do
        @resource.save  
        refute_empty @resource.errors.messages, "callbacks did not run. Should populate error array"
        assert_equal( { id: [ "something something" ] }, @resource.errors.messages )
      end
    end
  end

  def test_update_attributes_runs_callbacks
    @resource.client.stub :update_attributes, User.new({}) do
      assert_empty @resource.errors.messages
      
      @resource.client.stub :errors, {id: "something something"} do
        @resource.update_attributes id: -5
        refute_empty @resource.errors.messages, "callbacks did not run. Should populate error array"
        assert_equal( { id: [ "something something" ] }, @resource.errors.messages )
      end
    end
  end

  def test_method_missing_falls_through_to_client
    assert_equal User.site, UserResource.site
    assert_equal :no_name, @resource.no_name

    User.stub :search, JsonApiClient::ResultSet.new([User.new()]) do
      result = UserResource.search id: 6
      refute_empty result
      assert_equal 1, result.count
      assert_equal UserResource, result.first.class
    end

    UserResource.attribute_count = 6

    assert_equal UserResource.attribute_count, User.attribute_count
  end

  def test_method_missing_handles_argument_errors
    assert_raises JsonApiResource::JsonApiResourceError do
      UserResource.site 6
    end

    begin
      UserResource.site 6
    rescue => e
      assert_equal "UserResource: site: wrong number of arguments (1 for 0)", e.message
    end

    assert_raises JsonApiResource::JsonApiResourceError do
      @resource.no_name 6
    end

    begin
      @resource.no_name 6
    rescue => e
      assert_equal "UserResource: no_name: wrong number of arguments (1 for 0)", e.message
    end
  end

  def test_respond_to_method_missing_falls_through_to_client
    assert UserResource.respond_to? :site
    assert UserResource.method :site
    assert @resource.respond_to? :no_name
    assert @resource.method :no_name
  end

  def test_client_errors_are_handled_on_save
    @resource.client.stub :save, raise_client_error! do
      @resource.save
      assert_equal( { ServerError: ["Internal server error at: http://localhost:3000/api/1"] }, @resource.errors.messages )
    end
  end

  def test_client_errors_are_handled_on_update
    @resource.client.stub :update_attributes, raise_client_error! do
      @resource.update_attributes id: -5
      assert_equal( { ServerError: ["Internal server error at: http://localhost:3000/api/1"] }, @resource.errors.messages )
    end
  end

  def test_client_errors_are_handled_method_missing
    @resource.client.stub :no_name, raise_client_error! do
      @resource.no_name
      assert_equal( { ServerError: ["Internal server error at: http://localhost:3000/api/1"] }, @resource.errors.messages )
    end

    User.stub :attribute_count, raise_client_error! do
      response = UserResource.attribute_count
      assert_equal( { ServerError: ["Internal server error at: http://localhost:3000/api/1"] }, response.errors.messages )
    end
  end
end