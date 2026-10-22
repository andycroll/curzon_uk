require_relative '../../test_helper'

class CurzonUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil CurzonUk::VERSION
  end
end
