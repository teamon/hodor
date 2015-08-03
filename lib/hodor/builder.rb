module Hodor
  class Builder
    BASE_IMAGE = "gliderlabs/herokuish"

    attr_reader :app_path, :image

    def initialize(app_path)
      @app_path = app_path
    end

    def image_name
      File.basename(app_path)
    end

    def copy_app_into_container(io)
      container = Docker::Container.create(
        "Image"     => BASE_IMAGE,
        "Cmd"       => ["/bin/bash", "-c", "mkdir -p /app && tar -xC /app"],
        "OpenStdin" => true,
        "StdinOnce" => true,
        "Env"       => ["PORT=3000"]
      )

      container.start
      container.attach(stdin: io)

      image = container.commit(repo: image_name, tag: "build-#{rand(10000)}")

      yield container, image
    ensure
      container.remove(force: true) if container
      image.remove(force: true) if image
    end

    def build_with_buildpack(image)
      container = Docker::Container.create(
        "Image" => image.id,
        "Cmd"   => ["/bin/bash", "-c", "/bin/herokuish buildpack build"],
      )

      container.start
      container.streaming_logs(stdout: true, follow: true) { |stream, chunk| puts chunk }
      container.wait
      yield container
    ensure
      container.remove(force: true) if container
    end

    def build
      Docker.validate_version!

      source do |io|
        copy_app_into_container(io) do |container, image|
          build_with_buildpack(image) do |container|
            @image = container.commit(repo: image_name)
          end
        end
      end
    end

    def source(&block)
      Dir.chdir(app_path) do
        local_read(&block)
      end
    end

    def git_archive(&block)
      IO.popen("git archive HEAD", &block)
    end

    def local_read(&block)
      IO.popen("tar -c .", &block)
    end
  end
end
