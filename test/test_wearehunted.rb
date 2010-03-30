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
    
    should "limit the number of results when requested" do
      stub_get('http://wearehunted.com/api/suggest/singles/?name=Shakira&count=5', 'shakira_suggest_limited.json')
      suggestions = WeAreHunted.suggest(:name => "Shakira", :count => 5)
      assert_equal 5, suggestions.size
    end

    should "return links for requested providers" do
      stub_get('http://wearehunted.com/api/suggest/singles/?name=Shakira&provider=itunes&provider=grooveshark', 'shakira_itunes_grooveshark.json')
      suggestions = WeAreHunted.suggest(:name => "Shakira", :provider => ["itunes", "grooveshark"])
      assert_equal 10, suggestions.size
      first = suggestions.first
      assert_equal 'Say Hi', first['artist']
      providers = first['links']
      assert_equal nil, providers['itunes']
      assert_equal "http://listen.grooveshark.com/#/song/Oh Oh Oh Oh Oh Oh Oh Oh/22791511", providers["grooveshark"]
    end
  end
  
end
