require File.expand_path('../test_helper', __FILE__)

class SupremeTest < Test::Unit::TestCase
  def setup
    Supreme.reset!
  end
  
  def test_uses_test_mode_by_default
    assert_equal :test, Supreme.mode
  end
  
  def test_holds_a_different_mode
    Supreme.mode = :live
    assert_equal :live, Supreme.mode
  end
  
  def test_translate_hash_keys
    assert_equal({}, Supreme.translate_hash_keys({}, {}))
    assert_equal({'a' => 1}, Supreme.translate_hash_keys({}, {'a' => 1}))
    assert_equal({'a' => 1, 'b' => 2}, Supreme.translate_hash_keys({'baby' => 'b'}, {'a' => 1, 'baby' => 2}))
    assert_equal({'a' => 1, 'b' => 2}, Supreme.translate_hash_keys({:baby => 'b'}, {'a' => 1, 'baby' => 2}))
    assert_equal({'a' => 1, 'b' => 2}, Supreme.translate_hash_keys({'baby' => 'b'}, {'a' => 1, :baby => 2}))
    assert_equal({'a' => 1, 'b' => 2}, Supreme.translate_hash_keys({:baby => 'b'}, {:a => 1, :baby => 2}))
  end
  
  def test_holds_a_partner_id
    Supreme.partner_id = '678234'
    assert_equal '678234', Supreme.partner_id
  end
  
  def test_returns_an_API_instance
    api = Supreme.api
    assert api.kind_of?(Supreme::API)
  end
  
  def test_returns_an_API_instance_based_on_the_settings
    Supreme.partner_id = '678234'
    api = Supreme.api
    assert_equal '678234', api.partner_id
  end
end