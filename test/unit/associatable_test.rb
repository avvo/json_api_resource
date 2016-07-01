require 'test_helper'

class AssociatableTest < MiniTest::Test

  def test_derived_class
    assert_equal "Account::V1::User", Account::V1::Attribute.send( :derived_class, :user )
    assert_equal "Account::V1::User", Account::V1::Attribute.send( :derived_class, "user" )
    
    assert_equal "UserResource", UserResource.send( :derived_class, :user_resource )
    assert_equal "UserResource", UserResource.send( :derived_class, "user_resource" )
  end

  def test_belongs_to_creates_correct_method
    assert Account::V1::Attribute.new.respond_to? :user
  end

  def test_belongs_to_works_with_impicit_class
    Account::Client::User.stub :find, JsonApiClient::ResultSet.new([User.new(id: 2)]) do
      attribute = Account::V1::Attribute.new({id: 1, user_id: 2})
      result = attribute.user
      refute_nil result
      assert_equal Account::V1::User, result.class
      assert_equal 2, result.id
    end
  end

  def test_belongs_to_works_with_expicit_class
    Account::Client::PartnerUser.stub :find, JsonApiClient::ResultSet.new([User.new(id: 2)]) do
      user = Account::V1::User.new({id: 1, associated_website_user_id: 2})
      result = user.associated_website_user
      refute_nil result
      assert_equal Account::V1::PartnerUser, result.class
      assert_equal 2, result.id
    end
  end



end