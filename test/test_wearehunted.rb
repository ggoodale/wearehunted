require 'helper'

class TestWearehunted < Test::Unit::TestCase
  should "have a suggest method for retrieving artist suggestions" do
    stub_get('http://wearehunted.com/api/suggest/singles/?name=Shakira', 'shakira_suggest.json')
    suggestions = WeAreHunted.suggest(:name => "Shakira")
    assert_equal 10, suggestions.size
    first = suggestions.first
    assert_equal 'Say Hi', first['artist']
  end
  
  context "has a suggest method that" do 
    should "accept multiple artist names" do
      stub_get('http://wearehunted.com/api/suggest/singles/?name=Madonna&name=Shakira', 'madonna_shakira_suggest.json')
      suggestions = WeAreHunted.suggest(:name => ["Madonna", "Shakira"])
      assert_equal 10, suggestions.size
      first = suggestions.first
      assert_equal 'Burning Hearts', first['artist']
    end
  end
  
end
