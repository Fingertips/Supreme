require File.expand_path('../test_helper', __FILE__)

class BasicTest < Test::Unit::TestCase
  def setup
    Supreme.mode = :test
  end
  
  def test_banklist
    banklist = Supreme.api.banklist
    assert !banklist.to_a.empty?
  end
end