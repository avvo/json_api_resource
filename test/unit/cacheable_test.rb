require 'test_helper'

class CacheableTest < MiniTest::Test

  def setup
    @resource = UserResource.new({id: 2, name: "Brandon Sislow"})
  end

  def test_can_generate_cache
    refute_nil @resource.cache_key
  end

  def test_identical_objects_will_generate_the_same_key
    new_key = UserResource.new({id: 2, name: "Brandon Sislow"}).cache_key
    assert_equal new_key, @resource.cache_key
  end

  def test_different_objects_will_generate_different_keys
    new_key = UserResource.new({id: 2, name: "not Brandon Sislow"}).cache_key
    refute_equal new_key, @resource.cache_key
  end

end