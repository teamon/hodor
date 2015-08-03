require 'stringio'

class CaptureIO
  def initialize(log = nil)
    @log  = log
    @io   = StringIO.new
  end

  def write(*args, &block)
    @io.write(*args, &block)
    @log.write(*args, &block)
  end

  def flush(*args, &block)
    @io.flush(*args, &block)
    @log.flush(*args, &block)
  end

  def string
    @io.string
  end

  class << self
    def verbose_combined(&block)
      io = self.new(STDOUT)
      capture(io, io, &block).first
    end

    def verbose(&block)
      capture(self.new(STDOUT), self.new(STDERR), &block)
    end

    def silent(&block)
      capture(StringIO.new, StringIO.new, &block)
    end

    def capture(captured_stdout, captured_stderr)
      mutex.synchronize do
        begin
          orig_stdout, orig_stderr = $stdout, $stderr
          $stdout, $stderr         = captured_stdout, captured_stderr

          yield

          [captured_stdout.string, captured_stderr.string]
        ensure
          $stdout = orig_stdout
          $stderr = orig_stderr
        end
      end
    end

    def mutex
      @mutex ||= Mutex.new
    end
  end
end
