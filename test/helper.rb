require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'fakeweb'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'wearehunted'

class Test::Unit::TestCase
  def stub_get(url, filename, status=nil)
    options = {:body => fixture_file(filename)}
    options.merge!({:status => status}) unless status.nil?
    FakeWeb.register_uri(:get, url, options)
  end

  def fixture_file(filename)
    file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
    File.read(file_path)
  end
end
