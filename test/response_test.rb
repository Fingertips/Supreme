require File.expand_path('../test_helper', __FILE__)

class StatusTest < Test::Unit::TestCase
  def test_boolean_status_accessors
    status = Supreme::Status.new(stub)
    status.stubs(:status).returns('Failure')
    
    assert !status.open?
    assert !status.success?
    assert !status.cancelled?
    assert status.failed?
    assert !status.expired?
    assert !status.checked_before?
  end
end
