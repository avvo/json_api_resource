require 'test_helper'

class AssociationPreloaderTest < MiniTest::Test
  
  def setup
    @users =  [ Account::V1::User.new( id: 1, permission_ids: [1, 2] ), 
                Account::V1::User.new( id: 2, permission_ids: [3, 4] ),
              ]

    @attrs =  [ Account::Client::Attribute.new( id: 1, user_id: 1 ),
                Account::Client::Attribute.new( id: 2, user_id: 1 ),
                Account::Client::Attribute.new( id: 3, user_id: 2 ),
                Account::Client::Attribute.new( id: 4, user_id: 1 ),
              ]
  end

  def test_belongs_to_bulk_query
    users = (1..10).map do |id|
      Account::V1::User.new({id: id, associated_website_user_id: id})
    end

    bt = Account::V1::User._associations[:associated_website_user]

    bt = JsonApiResource::Associations::Preloaders::BelongsToPreloader.new(bt)

    assert bt.bulk_query(users).keys.include? :id
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], bt.bulk_query(users)[:id]
  end

  def test_has_one_bulk_query
    users = (1..10).map do |id|
      Account::V1::User.new({id: id})
    end

    ho = Account::V1::User._associations[:address]
    ho = JsonApiResource::Associations::Preloaders::HasOnePreloader.new(ho)

    assert ho.bulk_query(users).keys.include? :user_id
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], ho.bulk_query(users)[:user_id]

    ho = Account::V1::User._associations[:thing]
    ho = JsonApiResource::Associations::Preloaders::HasOnePreloader.new(ho)

    assert ho.bulk_query(users).keys.include? :person_id
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], ho.bulk_query(users)[:person_id]
  end

  def test_has_many_bulk_query
    users = (1..10).map do |id|
      Account::V1::User.new({id: id})
    end

    hm = Account::V1::User._associations[:address]
    hm = JsonApiResource::Associations::Preloaders::HasManyPreloader.new(hm)

    assert hm.bulk_query(users).keys.include? :user_id
    assert_equal [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], hm.bulk_query(users)[:user_id]
  end

  def test_has_many_prefetched_bulk_query
    users = (1..10).map do |id|
      Account::V1::User.new({id: id, permission_ids: [2, 3]})
    end

    hmp = Account::V1::User._associations[:permissions]
    hmp = JsonApiResource::Associations::Preloaders::HasManyPrefetchedPreloader.new(hmp)

    assert hmp.bulk_query(users).keys.include? :id
    assert_equal [2, 3], hmp.bulk_query(users)[:id]
  end

  def test_belongs_to_preloader_correctly_assigns_objects
    users = (1..4).map do |id|
      Account::V1::User.new({id: id, associated_website_user_id: id})
    end

    bt = Account::V1::User._associations[:associated_website_user]

    bt = JsonApiResource::Associations::Preloaders::BelongsToPreloader.new(bt)

    assert_equal [1, 2, 3, 4], bt.bulk_query(users)[:id]
  end

  def test_preload_validates_and_distributes_objects
    association = JsonApiResource::Associations::HasMany.new( Account::V1::User, 
                                                              :attrs, 
                                                              class: Account::V1::Attribute )

    preloader =  JsonApiResource::Associations::Preloaders::HasManyPreloader.new association

    Account::Client::Attribute.stub :where, JsonApiClient::Scope.new({}) do
      Account::Client::Attribute.where.stub :all, JsonApiClient::ResultSet.new(@attrs) do
        preloader.preload @users
      end
    end
    assert_equal @attrs.select{|r| r.user_id == 1}.map(&:id), @users.first.attrs.map(&:id)
  end


  def test_preloader_base_raises
    assert_raises NotImplementedError do
      base = JsonApiResource::Associations::Preloaders::Base.new nil
    end
  end

  def test_preloader_correctly_identifies_associations
    association = Account::V1::User._associations[:attrs]
    assert_equal association, JsonApiResource::Associations::Preloader.send( :association_for, @users, :attrs )

    association = Account::V1::User._associations[:permissions]
    assert_equal association, JsonApiResource::Associations::Preloader.send( :association_for, @users, :permissions )
  
    association = Account::V1::User._associations[:associated_website_user]
    assert_equal association, JsonApiResource::Associations::Preloader.send( :association_for, @users, :associated_website_user )
  
    association = Account::V1::User._associations[:address]
    assert_equal association, JsonApiResource::Associations::Preloader.send( :association_for, @users, :address )
  
  end

  def test_preloader_end_to_end
    Account::Client::Attribute.stub :where, JsonApiClient::Scope.new({}) do
      Account::Client::Attribute.where.stub :all, JsonApiClient::ResultSet.new(@attrs) do
        JsonApiResource::Associations::Preloader.preload @users, :attrs
      end
    end
    assert_equal @attrs.select{|r| r.user_id == 1}.map(&:id), @users.first.attrs.map(&:id)
  end

end