require 'minitest_helper'

class AppSimpleRubyTest < Minitest::Test
  include Minitest::Hooks
  include AppBuilder

  def before_all
    @containers_count = Docker::Container.all(all: true).size
    @images_count     = Docker::Image.all(all: true).size

    puts "@images_count @images_count @images_count #{@images_count}"

    build!("simple-ruby")
    super
  end

  def after_all
    builder.image.remove(force: true)
    super
  end


  def test_image_name
    assert_equal "simple-ruby", builder.image_name
  end

  def test_docker_image_created
    assert Docker::Image.exist?("simple-ruby")
  end

  def test_ruby_app_detected
    assert_match /Ruby app detected/, stdout
  end

  def test_installing_rack
    assert_match /Installing rack/, stdout
  end

  def test_successful_bundle
    assert_match /Bundle completed/, stdout
  end

  def test_installed_ruby_version
    assert_match /ruby 2.0.0/, app_exec("ruby -v")
  end

  def test_pwd
    assert_equal "/app", app_exec("pwd")
  end

  def test_web_app
    app_start("web") do |container|
      out, err = try_exec(container, ["curl", "--silent", "localhost:3000"], 10)
      assert_match /Simple Ruby App/, out.join("\n")
    end
  end

  def test_cleanup_all_containers
    assert_equal @containers_count, Docker::Container.all(all: true).size
  end

  def test_cleanup_intermidiate_images
    # Full build should create one new image
    skip "something is wrong here..."
    assert_equal (@images_count + 1), Docker::Image.all(all: true).size
  end
end
