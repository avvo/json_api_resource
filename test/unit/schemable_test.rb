require 'test_helper'

class SchemableTest < MiniTest::Test

  def test_schemable_through_class_definition
    assert_equal( { id: nil, name: "" }, UserResource.schema )
  end

  def test_schemable_through_single_property
    assert_equal( {id: nil, name: "", updated_at: nil}, PropUserResource.schema )
  end

  def test_schemable_though_properties_hash
    assert_equal( {id: nil, name: "", updated_at: nil}, PropsUserResource.schema )
  end

  def test_schemable_though_combination_of_properties
    assert_equal( {id: nil, name: "", updated_at: nil}, PropPropsUserResource.schema )
  end

  def test_omitted_fields_populate_with_defaults
    @user = UserResource.new(client: User.new())
    assert @user.id
    assert @user.name

    @user = UserResource.new(client: User.new( id: 4 ))
    assert_equal 4, @user.id
    assert @user.name
  end
end