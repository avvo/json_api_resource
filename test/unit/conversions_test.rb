require 'test_helper'

class ConversionsTest < MiniTest::Test
  include JsonApiResource::Conversions

#------------- ApiErrors -------------

  def test_api_errors_can_parse_api_errors
    errors = ActiveModel::Errors.new({})
    assert_equal ActiveModel::Errors, ApiErrors(errors).class
  end

  def test_api_errors_can_parse_hash
    errors  = { error: :bad }
    assert_equal errors, ApiErrors(errors)
  end

  def test_api_errors_can_parse_array
    errors = [:good, :bad, :ugly]
    assert_equal( { base: [errors] }, ApiErrors(errors) )
  end

  def test_api_errors_can_parse_string
    errors = "Error. lol"
    assert_equal( { base: [[errors]] }, ApiErrors(errors) )
  end

  def test_api_errors_raises_on_garbage_input
    assert_raises TypeError do
      ApiErrors(User.new())
    end
  end

#--------------- Date ----------------

  def test_date_can_parse_string
    assert_equal Date, Date("21-01-2015").class
  end

  def test_date_can_parse_date
    assert_equal Date, Date(Date.new).class
  end

  def test_date_raises_on_garbage_input
    assert_raises TypeError do
      Date(User.new())
    end
  end

#------------- DateTime --------------

  def test_date_time_can_parse_string
    assert_equal DateTime, DateTime("21-01-2015").class
  end

  def test_date_time_can_parse_date
    assert_equal DateTime, DateTime(DateTime.new).class
  end

  def test_date_time_raises_on_garbage_input
    assert_raises TypeError do
      DateTime(User.new())
    end
  end
  
#-------------- Boolean --------------
  
  def test_boolean_can_parse_boolean
    assert_equal true, Boolean(true)
    assert_equal false, Boolean(false)
  end

  def test_boolean_can_parse_string
    assert_equal true, Boolean("true")
    assert_equal true, Boolean("1")

    assert_equal false, Boolean("false")
    assert_equal false, Boolean("0")
  end

  def test_boolean_can_parse_integer
    assert_equal true, Boolean(15)

    assert_equal false, Boolean(0)
  end

  def test_boolean_raises_on_garbage_string
    assert_raises TypeError do
      Boolean("LOL NOT TRUE")
    end
  end

  def test_boolean_raises_on_garbage_input
    assert_raises TypeError do
      Boolean(User.new())
    end
  end

#------------ ApiResource ------------
  
  def test_api_resource_can_parse_reource
    assert_equal UserResource, ApiResource(UserResource, UserResource.new()).class
  end

  def test_api_resource_can_parse_hash
    assert_equal UserResource, ApiResource(UserResource, {}).class
  end

  def test_api_resource_can_parse_client
    assert_equal UserResource, ApiResource(UserResource, User.new()).class
  end

  def test_api_resource_can_parse_array
    assert_equal Array, ApiResource(UserResource, [{}, User.new(), UserResource.new()]).class
  end

  def test_api_resource_raises_on_garbage_input
    assert_raises TypeError do
      ApiResource(UserResource, "LOL NOT A RESOURCE")
    end
  end

end