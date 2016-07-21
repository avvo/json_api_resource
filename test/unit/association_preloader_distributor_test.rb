require 'test_helper'

class AssociationPreloaderDistributorTest < MiniTest::Test

  def setup
    @users =  [ Account::V1::User.new( id: 1, permission_ids: [1, 2] ), 
                Account::V1::User.new( id: 2, permission_ids: [3, 4] ),
              ]

    @attrs =  [ Account::V1::Attribute.new( id: 1, user_id: 1 ),
                Account::V1::Attribute.new( id: 2, user_id: 1 ),
                Account::V1::Attribute.new( id: 3, user_id: 2 ),
                Account::V1::Attribute.new( id: 4, user_id: 1 ),
              ]

    @perms =  [ Account::V1::Permission.new( id: 1 ),
                Account::V1::Permission.new( id: 2 ),
                Account::V1::Permission.new( id: 3 ),
                Account::V1::Permission.new( id: 4 ),
              ]

    @things = [ Account::V1::Thing.new( {} ),
                Account::V1::Thing.new( {} ),
                Account::V1::Thing.new( {} ),
                Account::V1::Thing.new( {} ),
              ]

  end

  def test_base_distributor_raises
    assert_raises NotImplementedError do
      JsonApiResource::Associations::Preloaders::Distributors::Base.new( nil ).send :validate_assignability!, []
    end

    assert_raises NotImplementedError do
      JsonApiResource::Associations::Preloaders::Distributors::Base.new( nil ).send :assign, [], []
    end
  end

  def test_distributor_by_object_id_correctly_assigns_results_to_targets
    association = JsonApiResource::Associations::HasMany.new( Account::V1::User, 
                                                              :attrs, 
                                                              class: Account::V1::Attribute )

    distributor =  JsonApiResource::Associations::Preloaders::Distributors::DistributorByObjectId.new association

    distributor.distribute @users, @attrs

    assert_equal @attrs.select{|r| r.user_id == 1}, @users.first.attrs
  end

  def test_distributor_by_object_id_validates_assignability
    association = JsonApiResource::Associations::HasMany.new( Account::V1::User, 
                                                              :things )

    distributor =  JsonApiResource::Associations::Preloaders::Distributors::DistributorByObjectId.new association

    assert_raises JsonApiResource::Errors::InvalidAssociation do
      distributor.validate_assignability! @things
    end
  end


  def test_distributor_by_target_id_correctly_assigns_results_to_targets
    association = JsonApiResource::Associations::HasManyPrefetched.new( Account::V1::User, 
                                                              :permissions, 
                                                              prefetched_ids: :permission_ids )

    distributor =  JsonApiResource::Associations::Preloaders::Distributors::DistributorByTargetId.new association

    distributor.distribute @users, @perms

    assert_equal @perms[0..1], @users.first.permissions
    assert_equal @perms[2..3], @users.last.permissions
  end

  def test_distributor_by_target_id_validates_assignability

    association = JsonApiResource::Associations::HasManyPrefetched.new( Account::V1::User, 
                                                              :permissions, 
                                                              prefetched_ids: :permission_ids )

    distributor =  JsonApiResource::Associations::Preloaders::Distributors::DistributorByTargetId.new association

    assert_raises JsonApiResource::Errors::InvalidAssociation do
      distributor.validate_assignability! @things
    end
  end
end