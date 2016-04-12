require 'test_helper'

class ClientableTest < MiniTest::Test

  def test_wraps_sets_client
    assert_equal User, UserResource.client_class
  end

  def test_wraps_overrides_previous_class
    assert_equal User, PropUserResource.client_class
    PropUserResource.wraps Attribute
    assert_equal Attribute, PropUserResource.client_class

    # let's reset the client
    UserResource.wraps User
    PropUserResource.wraps User
  end

  def test_throws_if_no_client_present
    assert_raises JsonApiResource::JsonApiResourceError do
      JsonApiResource::Resource.new({})
    end
  end
end