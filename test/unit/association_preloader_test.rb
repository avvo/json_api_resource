require 'test_helper'

class AssociationPreloaderTest < MiniTest::Test
  
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

  def test_belongs_to_preloader_explodes_on_unassignable_results

  end


  def test__preloader_correctly_assigns_objects

  end

  def test__preloader_explodes_on_unassignable_results

  end


  def test_preloader

  end

end