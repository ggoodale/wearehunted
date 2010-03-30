require 'helper'

class TestWearehunted < Test::Unit::TestCase
  should "implement something" do
    assert_not_nil WeAreHunted.suggest(:name => "Shakira")
  end
end
