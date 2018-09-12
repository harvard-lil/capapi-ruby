# frozen_string_literal: true

require ::File.expand_path("../test_helper", __FILE__)

class CapapiTest < Test::Unit::TestCase
  should "allow max_network_retries to be configured" do
    begin
      old = Capapi.max_network_retries
      Capapi.max_network_retries = 99
      assert_equal 99, Capapi.max_network_retries
    ensure
      Capapi.max_network_retries = old
    end
  end

  should "have default open and read timeouts" do
    assert_equal Capapi.open_timeout, 30
    assert_equal Capapi.read_timeout, 80
  end
end
