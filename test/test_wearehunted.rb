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
    
    should "accept artist ids" do
      stub_get('http://wearehunted.com/api/suggest/singles/?artist=3024&artist=48452&artist=48031', 'jennifer_lopez_shakira_suggest.json')
      artist_ids = [3024, 48452, 48031]
      suggestions = WeAreHunted.suggest(:artist => artist_ids)
      assert_equal 10, suggestions.size
      first = suggestions.first
      assert_equal 'Taio Cruz', first['artist']
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
      stub_get('http://wearehunted.com/api/chart/singles/1/?provider=itunes&provider=grooveshark', 'twitter_daily_chart_itunes_grooveshark.json')
      chart = WeAreHunted.chart(:type => :singles, :period => 1, :provider => ["itunes", "grooveshark"])
      assert_equal 10, chart.size
      first = chart.first
      assert_equal 'DELOREAN', first['artist']
      providers = first['links']
      assert_equal nil, providers['itunes']
      assert_equal "http://listen.grooveshark.com/#/song/Stay close/24993632", providers["grooveshark"]
    end    
  end  
  
  should "have and artist method for retrieving artist IDs" do
    stub_get('http://wearehunted.com/api/lookup/artist/?text=Shakira', 'artist_shakira.json')
    result = WeAreHunted.artist("Shakira")
    assert_equal 1, result.size
    assert_equal 48031, result[0]    
  end
  
  context "has an artist method that" do
    should "return artist ids for artists identified in a block of text" do
      text = "After achieving superstardom throughout Latin America, Colombian-born Shakira became Latin pop's biggest female crossover artist since Jennifer Lopez. Noted for her aggressive, rock-influenced approach."
      stub_get("http://wearehunted.com/api/lookup/artist/?text=#{URI.escape(text)}", 'artist_shakira_blog_post.json')
      result = WeAreHunted.artist(text)
      assert_equal 3, result.size
      assert_equal [3024, 48452, 48031], result
    end
    
    should "handle arrays of artist names" do
      stub_get("http://wearehunted.com/api/lookup/artist/?name=Shakira&name=Broken%20Bells", 'artist_shakira_broken_bells.json')
      result = WeAreHunted.artist("Shakira", "Broken Bells")
      assert_equal 2, result.size
      assert_equal [100008, 48031], result
    end
  end
end
