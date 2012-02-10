require File.expand_path('../test_helper', __FILE__)

class SupremeTest < Test::Unit::TestCase
  def test_stuff
    @supreme = Supreme.new
    assert @supreme
  end
end