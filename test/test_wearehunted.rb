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
  
  should "have a chart method for retrieving charts" do
    stub_get('http://wearehunted.com/api/chart/singles/1/', 'default_daily_singles_chart.json')
    chart = WeAreHunted.chart(:type => :singles, :period => 1)
    assert_equal 10, chart.size
    first = chart.first
    assert_equal 'DELOREAN', first['artist']
  end
  
  context "has a chart method that" do 
    should "raise an exception if required parameters are missing" do
      assert_raises(ArgumentError){WeAreHunted.chart(:name => "rock")}
      assert_raises(ArgumentError){WeAreHunted.chart(:name => "rock", :type => :artists)}
      assert_raises(ArgumentError){WeAreHunted.chart(:name => "rock", :type => :genres, :period => 7)}
      assert_raises(ArgumentError){WeAreHunted.chart(:name => "rock", :type => :artists, :period => 14)}
    end
    
    should "limit the number of results when requested" do
      stub_get('http://wearehunted.com/api/chart/singles/1/?count=5', 'default_daily_singles_chart_limited.json')
      suggestions = WeAreHunted.chart(:type => :singles, :period => 1, :count => 5)
      assert_equal 5, suggestions.size
    end
    
    should "return links for requested providers" do
      stub_get('http://wearehunted.com/api/chart/twitter/singles/1/?provider=itunes&provider=grooveshark', 'twitter_daily_chart_itunes_grooveshark.json')
      chart = WeAreHunted.chart(:type => :singles, :period => 1, :provider => ["itunes", "grooveshark"])
      assert_equal 10, chart.size
      first = chart.first
      assert_equal 'DELOREAN', first['artist']
      providers = first['links']
      assert_equal nil, providers['itunes']
      assert_equal "http://listen.grooveshark.com/#/song/Stay close/24993632", providers["grooveshark"]
    end
  end  
end
