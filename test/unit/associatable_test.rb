require 'test_helper'

class AssociatableTest < MiniTest::Test

  def test_derived_class
    assert_equal Account::V1::User, JsonApiResource::Associations::BelongsTo.new( Account::V1::Attribute, :user ).klass
    assert_equal Account::V1::User, JsonApiResource::Associations::BelongsTo.new( Account::V1::Attribute, "user" ).klass
    
    assert_equal UserResource, JsonApiResource::Associations::BelongsTo.new( UserResource, :user_resource ).klass
    assert_equal UserResource, JsonApiResource::Associations::BelongsTo.new( UserResource, "user_resource" ).klass
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

  def test_belongs_to_caches_result
    attribute = Account::V1::Attribute.new({id: 1, user_id: 2})
    Account::Client::User.stub :find, JsonApiClient::ResultSet.new([User.new(id: 2)]) do
      result = attribute.user
      refute_nil result
      assert_equal Account::V1::User, result.class
      assert_equal 2, result.id
    end

    assert attribute.user
  end

  def test_belongs_to_with_nil_id_doesnt_make_http_call
    user = Account::V1::User.new({})
    result = user.associated_website_user
    assert_nil result
  end

  def test_has_one_creates_correct_method
    assert Account::V1::User.new.respond_to? :profile_image
    assert Account::V1::User.new.respond_to? :address
  end

  def test_has_one_works_with_impicit_class
    Account::Client::Address.stub :where, JsonApiClient::Scope.new(user_id: 6) do
      Account::Client::Address.where.stub :all, JsonApiClient::ResultSet.new([Account::Client::Address.new(id: 2, user_id: 6)]) do
        user = Account::V1::User.new({id: 6})
        result = user.address
        refute_nil result
        assert_equal Account::V1::Address, result.class
        assert_equal 6, result.user_id
      end
    end
  end

  def test_has_one_works_with_expicit_class
    Account::Client::Image.stub :where, JsonApiClient::Scope.new(user_id: 6) do
      Account::Client::Image.where.stub :all, JsonApiClient::ResultSet.new([Account::Client::Image.new(id: 2, user_id: 6)]) do
      
        user = Account::V1::User.new({id: 1, associated_website_user_id: 2})
        result = user.profile_image
        refute_nil result
        assert_equal Account::V1::Image, result.class
        assert_equal 2, result.id
      end
    end
  end

  def test_has_one_caches_result
    user = Account::V1::User.new({id: 6})
    Account::Client::Address.stub :where, JsonApiClient::Scope.new(user_id: 6) do
      Account::Client::Address.where.stub :all, JsonApiClient::ResultSet.new([Account::Client::Address.new(id: 2, user_id: 6)]) do
        result = user.address
        refute_nil result
        assert_equal Account::V1::Address, result.class
        assert_equal 6, result.user_id
      end
    end

    assert user.address
  end

  def test_has_many_creates_correct_method
    assert Account::V1::User.new.respond_to? :attrs
    assert Account::V1::User.new.respond_to? :friendships
  end

  def test_has_many_works_with_impicit_class
    Account::Client::Friendship.stub :where, JsonApiClient::Scope.new(user_id: 6) do
      Account::Client::Friendship.where.stub :all, JsonApiClient::ResultSet.new([ Account::Client::Friendship.new(id: 2, user_id: 6), 
                                                                                  Account::Client::Friendship.new(id: 3, user_id: 6)]) do
        user = Account::V1::User.new({id: 6})
        result = user.friendships
        refute_nil result
        assert_equal JsonApiClient::ResultSet, result.class
        assert_equal [Account::V1::Friendship, Account::V1::Friendship], result.map(&:class)
        assert_equal [2, 3], result.map(&:id)
      end
    end
  end

  def test_has_many_works_with_expicit_class
    Account::Client::Attribute.stub :where, JsonApiClient::Scope.new(user_id: 6) do
      Account::Client::Attribute.where.stub :all, JsonApiClient::ResultSet.new([ Account::Client::Attribute.new(id: 2, user_id: 6), 
                                                                                 Account::Client::Attribute.new(id: 3, user_id: 6)]) do
        user = Account::V1::User.new({id: 1, associated_website_user_id: 2})
        result = user.attrs
        refute_nil result
        assert_equal JsonApiClient::ResultSet, result.class
        assert_equal [Account::V1::Attribute, Account::V1::Attribute], result.map(&:class)
        assert_equal [2, 3], result.map(&:id)
      end
    end
  end

  def test_has_many_caches_result
    user = Account::V1::User.new({id: 6})
    Account::Client::Attribute.stub :where, JsonApiClient::Scope.new(user_id: 6) do
      Account::Client::Attribute.where.stub :all, JsonApiClient::ResultSet.new([ Account::Client::Attribute.new(id: 2, user_id: 6), 
                                                                                 Account::Client::Attribute.new(id: 3, user_id: 6)]) do
        user = Account::V1::User.new({id: 1, associated_website_user_id: 2})
        result = user.attrs
        refute_nil result
        assert_equal JsonApiClient::ResultSet, result.class
        assert_equal [Account::V1::Attribute, Account::V1::Attribute], result.map(&:class)
        assert_equal [2, 3], result.map(&:id)
      end
    end

    assert user.attrs
  end

  def test_has_many_prefetched_creates_correct_method
    assert Account::V1::User.new.respond_to? :permissions
  end

  def test_has_many_prefetched
    Account::Client::Permission.stub :where, JsonApiClient::Scope.new(id: [6, 7]) do
      Account::Client::Permission.where.stub :all, JsonApiClient::ResultSet.new([ Account::Client::Permission.new(id: 6, user_id: 6), 
                                                                                  Account::Client::Permission.new(id: 7, user_id: 6)]) do
        user = Account::V1::User.new({id: 6, permission_ids: [6, 7]})
        result = user.permissions
        refute_nil result
        assert_equal JsonApiClient::ResultSet, result.class
        assert_equal [Account::V1::Permission, Account::V1::Permission], result.map(&:class)
        assert_equal [6, 7], result.map(&:id)
      end
    end
  end

  def test_has_many_prefetched_caches_result
    user = Account::V1::User.new({id: 6, permission_ids: [6, 7]})

    Account::Client::Permission.stub :where, JsonApiClient::Scope.new(id: [6, 7]) do
      Account::Client::Permission.where.stub :all, JsonApiClient::ResultSet.new([ Account::Client::Permission.new(id: 6, user_id: 6), 
                                                                                  Account::Client::Permission.new(id: 7, user_id: 6)]) do
        result = user.permissions
        refute_nil result
        assert_equal JsonApiClient::ResultSet, result.class
        assert_equal [Account::V1::Permission, Account::V1::Permission], result.map(&:class)
        assert_equal [6, 7], result.map(&:id)
      end
    end

    assert user.permissions
  end

  def test_has_many_prefetched_with_nil_id_doesnt_make_http_call
    user = Account::V1::User.new({})
    result = user.permissions
    assert_equal [], result    

    user = Account::V1::User.new({permission_ids: nil})
    result = user.permissions
    assert_equal [], result
  end

  def test_associations_will_asplode_with_invalid_action
    assert_raises JsonApiResource::Errors::InvalidAssociation do
      UserResource.belongs_to :user_resource, action: nil
    end
  end

  def test_associations_will_asplode_with_invalid_foreign_key
    assert_raises JsonApiResource::Errors::InvalidAssociation do
      UserResource.has_one :prop_user_resource, foreign_key: nil
    end
  end

  def test_associations_will_asplode_with_reserved_keyword_as_assocaition_name
    JsonApiResource::Associations::Base::RESERVED_KEYWORDS.each do |keyword|
      assert_raises JsonApiResource::Errors::InvalidAssociation do
        Account::V1::User.has_many keyword
      end
    end
  end

  def test_association_objects_have_correct_types
    bt  = JsonApiResource::Associations::BelongsTo.new(UserResource, :user_prop_resource)
    ho  = JsonApiResource::Associations::HasOne.new(UserResource, :user_prop_resource)
    hm  = JsonApiResource::Associations::HasMany.new(UserResource, :user_prop_resource)
    hmp = JsonApiResource::Associations::HasManyPrefetched.new(UserResource, :user_prop_resource, prefetched_ids: :permissions_ids)

    assert_equal JsonApiResource::Associations::BELONGS_TO, bt.type
    assert_equal JsonApiResource::Associations::HAS_ONE, ho.type
    assert_equal JsonApiResource::Associations::HAS_MANY, hm.type
    assert_equal JsonApiResource::Associations::HAS_MANY_PREFETCHED, hmp.type
  end

  def test_base_association_raises
    assert_raises NotImplementedError do
      JsonApiResource::Associations::Base.new UserResource, :bla, class: UserResource
    end

    assert_raises NotImplementedError do
      JsonApiResource::Associations::Base.new UserResource, :bla, class: UserResource, action: :where
    end

    assert_raises NotImplementedError do
      JsonApiResource::Associations::Base.new( UserResource, :bla, class: UserResource, action: :where, foreign_key: :id ).type
    end

    assert_raises NotImplementedError do
      JsonApiResource::Associations::Base.new( UserResource, :bla, class: UserResource, action: :where, foreign_key: :id ).query( nil )
    end

    assert_raises NotImplementedError do
      JsonApiResource::Associations::Base.new( UserResource, :bla, class: UserResource, action: :where, foreign_key: :id ).callable?( nil )
    end

    assert_raises NotImplementedError do
      JsonApiResource::Associations::Base.new( UserResource, :bla, class: UserResource, action: :where, foreign_key: :id ).default_nil
    end
  end

  def test_non_query_opts_are_not_in_an_association_query
    attrs_association = Account::V1::User._associations[:attrs]
    perms_association = Account::V1::User._associations[:permissions]
    user              = Account::V1::User.new id: 5, permission_ids: [4]

    assert_equal( { user_id: 5, ignore_pagination: true }, attrs_association.query(user) )
    assert_equal( { id: [4], ignore_pagination: true }, perms_association.query(user) )
  end
end

