require 'test_helper'

class ClientableTest < MiniTest::Test

  def test_wraps_sets_client
    assert_equal UserClient, UserResource.client_class
  end

  def test_wraps_overrides_previous_class
    assert_equal UserClient, PropUserResource.client_class
    PropUserResource.wraps AttributeClient
    assert_equal AttributeClient, PropUserResource.client_class
  end

  def test_throws_if_no_client_present
    assert_raises JsonApiResource::JsonApiResourceError do
      JsonApiResource::Resource.new({})
    end
  end
end