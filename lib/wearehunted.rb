require "httparty"
require "json"

# A ruby wrapper around the We Are Hunted REST API.  Borrows heavily from
# jnunemaker's Twitter gem, though simplified greatly due to the simpler API.
module WeAreHunted
  include HTTParty
  API_VERSION = '0'.freeze
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
  #  allow_blanks: If true, return results that lack urls for one or more of the specified +providers+. defaults to false.
  #  include_seeds: If true, include the artists specified as seeds in the result set. defaults to false. 
  #  count: The maximum number of tracks that should be returned.
  #
  def self.suggest(options = {})
    perform_get("/suggest/singles/?#{query_string_from(options)}")
  end

  def self.chart(options = {})
    perform_get("/suggest/singles", options)
  end

  def self.artist(options = {})
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
    puts response.code.to_i
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
    options.inject([]) do |collection, opt|
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
