require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true)
]

require File.expand_path('../../../lib/curzon_uk.rb', __FILE__)
require_relative '../support/api_shapes'

CurzonUk.token = ENV.fetch('CURZON_TOKEN') { CurzonUk.acquire_token! }
