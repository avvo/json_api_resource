require 'test_helper'

class QuieriableTest < MiniTest::Test

  def setup
    @resource = UserResource.new({id: 1, name: "Brnadon Sislow"})
  end

end