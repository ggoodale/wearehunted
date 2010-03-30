require "httparty"
require "json"

# A ruby wrapper around the We Are Hunted REST API.  Borrows heavily from
# jnunemaker's Twitter gem, though simplified greatly due to the simpler API.
module WeAreHunted
  include HTTParty
  API_VERSION = 0
  CHART_TYPES = :artists, :singles
  CHART_PERIODS = 1, 7, 30
  
  base_uri "wearehunted.com/api"
  format :json
  
  class WeAreHuntedError < StandardError
    attr_reader :data
    def initialize(data)
      @data = data
      super      
    end
  end
  
  class BadRequest < WeAreHuntedError; end
  class RateLimitExceeded < WeAreHuntedError; end
  class NotFound < WeAreHuntedError; end
  class InformWeAreHunted < WeAreHuntedError; end
  class Unavailable < WeAreHuntedError; end

  # Retrieves suggested songs based on either a block of text or specific artist names.
  #  text: A block of text to search for known artist names.
  #  name: An artist name to use as a basis for suggestion. Multiple values can be passed in as an array. 
  #  artist: The We Are Hunted artist IDs to use as a basis for suggestion. Multiple values can be passed in as an array. See WeAreHunted::artist
  #  emerging: If true, include emerging artists in the result set.  defaults to false.
  #  provider: A provider to return urls for.  Multiple values can be passed in as an array. Valid options are: image, youtube, myspace, spotify, grooveshark, last.fm, itunes
  #  allow_blanks: If true, return results that lack urls for one or more of the specified providers. defaults to false.
  #  include_seeds: If true, include the artists specified as seeds in the result set. defaults to false. 
  #  count: The maximum number of tracks that should be returned.
  #
  def self.suggest(options = {})
    perform_get("/suggest/singles/#{query_string_from(options)}")["results"]
  end

  # Retrieves live chart data for the specified genre and type.
  #  name: The chart to retrieve.  May be one of:  rock, pop, folk, metal, alternative, electronic, punk, rap-hip-hop, twitter, remix
  #  type: The type of chart to retrieve.  May be one of: :artists, :singles 
  #  period: Specify the number of days covered by the chart.  May be one of: 1, 7, 30.
  #  user: Retrieve a chart created by a specific user.
  #  count: The maximum number of tracks that should be returned.
  #  provider: A provider to return urls for.  Multiple values can be passed in as an array. Valid options are: image, youtube, myspace, spotify, grooveshark, last.fm, itunes
  #  allow_blanks: If true, return results that lack urls for one or more of the specified providers. defaults to false.
  #
  def self.chart(options = {})
    chart_path = ""
    if options[:user]
      chart_path << "/by/#{options.delete(:user)}/"
    else

      unless options[:type] && CHART_TYPES.include?(options[:type])
        raise ArgumentError, ":type must be specified (one of artists, singles) when retrieving charts that aren't user-generated" 
      end
      
      unless options[:period] && CHART_PERIODS.include?(options[:period])
        raise ArgumentError, ":period must be specified (one of 1, 7, 30) when retrieving charts that aren't user-generated" 
      end

      if options[:name]
        chart_path << "/#{options.delete(:name)}"
      end

      chart_path << "/#{options.delete(:type)}/#{options.delete(:period)}/"
    end

    perform_get("/chart#{chart_path}#{query_string_from(options)}")["results"]
  end

  # Retrieves the We Are Hunted id for the specified artist(s).
  #  artists: One or more artist names to retrieve the id for.
  # 
  # Returns: a hash of artist name => artist id pairs
  #
  def self.artist(*artists)
    raise ArgumentError, "Please specify one or more artist names" if artists.empty?
    
    if artists.length == 1
      options = {:text => artists}
    else 
      options = {:name => artists}
    end
    
    result = perform_get("/lookup/artist/#{query_string_from(options)}")["results"]
    
    # The results don't include the artist names  (sigh), but we know they're returned in alphabetical order.
    Hash[*artists.sort.zip(result).flatten]
  end

  private
  
  def self.perform_get(uri, options = {}) # :nodoc:
    make_friendly(get(uri, options))
  end
  
  def self.make_friendly(response) # :nodoc:
    raise_errors(response)
    parse(response)
  end
  
  
  def self.raise_errors(response) # :nodoc:
    case response.code.to_i
    when 400
      raise BadRequest, "(#{response.code}): #{response.message}"
    when 404
      raise NotFound, "(#{response.code}): #{response.message}"
    when 500
      raise InformWeAreHunted, "We Are Hunted had an internal error. Please let them know. (#{response.code}): #{response.message}"
    when 502..503
      raise Unavailable, "(#{response.code}): #{response.message}"
    end
  end

  def self.parse(response) # :nodoc:
    return '' if response.body == ''
    JSON.parse(response.body)
  end
    
  def self.query_string_from(options) # :nodoc:
    return "" if options.empty?
    "?" << options.inject([]) do |collection, opt|
      case opt[1]
      when Array
        opt[1].each {|val| collection << "#{opt[0]}=#{val}"}
      else
        collection << "#{opt[0]}=#{opt[1]}"
      end
      collection 
    end * '&'
  end
end

directory = File.expand_path(File.dirname(__FILE__))

# require File.join(directory, "wearehunted", "suggest")
# require File.join(directory, "wearehunted", "chart")
# require File.join(directory, "wearehunted", "lookup")
