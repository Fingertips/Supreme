require File.expand_path('../test_helper', __FILE__)

class Supreme::URITest < Test::Unit::TestCase
  def test_does_not_escape_unreserved_characters
    unreserved = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ["-", ".", "_", "~"]
    unreserved.each do |character|
      assert_equal character, Supreme::URI.encode(character)
    end
  end
  
  def test_escapes_reserved_characters
    reserved = ['@', '&', '/']
    reserved.each do |character|
      assert_not_equal character, Supreme::URI.encode(character)
    end
  end
  
  def test_properly_escapes_spaces
    assert_equal '%20', Supreme::URI.encode(' ')
  end
  
  def test_roundtrips_generating_and_parsing_query_strings
    [
      {},
      {'a' => '1'},
      {'a' => '1', 'a' => '2'}
    ].each do |example|
      assert_equal example, Hash[Supreme::URI.parse_query(Supreme::URI.generate_query(example))]
    end
  end
end