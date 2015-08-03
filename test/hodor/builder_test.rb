require 'minitest_helper'

class BuilderTest < Minitest::Test
  def setup
    @builder = Hodor::Builder.new(File.expand_path("../../apps/simple-ruby", __FILE__))
  end

  def test_image_name
    assert @builder.image_name, "simple-ruby"
  end
end
