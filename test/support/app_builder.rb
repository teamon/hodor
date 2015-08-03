module AppBuilder
  def self.included(base)
    base.extend(ClassMethods)
  end

  [:builder, :stdout, :stderr, :build!].each do |meth|
    define_method(meth) do |*args|
      self.class.send(meth, *args)
    end
  end

  def app_exec(cmd)
    container = builder.image.run("/exec #{cmd}")
    container.wait
    container.logs(stdout: true, stdin: true)
             .gsub(/[\u0000-\u0010]/, "")
  ensure
    container.remove(force: true) if container
  end

  def app_start(proc)
    container = builder.image.run("/start #{proc}")

    yield container

    container.stop
  ensure
    container.remove(force: true) if container
  end

  def try_exec(container, cmd, timeout)
    Timeout.timeout(timeout) do
      loop do
        out, err, status = container.exec(cmd)
        return out, err if status == 0
        sleep 1
      end
    end
  end

  module ClassMethods
    def build!(app)
      @test_app = app
      log # just force load log
    end

    def builder
      @builder ||= Hodor::Builder.new(File.expand_path("../../apps/#{@test_app}", __FILE__))
    end

    def log
      @log ||= CaptureIO.verbose do
        builder.build
      end
    end

    def stdout
      log[0]
    end

    def stderr
      log[1]
    end
  end
end
