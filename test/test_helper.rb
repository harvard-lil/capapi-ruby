# frozen_string_literal: true

require "coveralls"
Coveralls.wear!("test_frameworks")

require "capapi"
require "test/unit"
require "mocha/setup"
require "stringio"
require "shoulda/context"
require "timecop"
require "webmock/test_unit"

PROJECT_ROOT = ::File.expand_path("../../", __FILE__)

# require ::File.expand_path("../test_data", __FILE__)

# If changing this number, please also change it in `.travis.yml`.
MOCK_MINIMUM_VERSION = "0.30.0".freeze
MOCK_PORT = ENV["STRIPE_MOCK_PORT"] || 12_111

# Disable all real network connections except those that are outgoing to
# stripe-mock.
WebMock.disable_net_connect!(allow: "localhost:#{MOCK_PORT}")

module Test
  module Unit
    class TestCase
      include Mocha

      setup do
        Capapi.api_key = "sk_test_123"
        Capapi.api_base = "http://localhost:#{MOCK_PORT}"
      end

      teardown do
        Capapi.api_key = nil
      end
    end
  end
end
