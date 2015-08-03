require "hodor"

module Hodor
  class CLI
    def call(argv)
      case argv[0]
      when "build"
        build
      else
        fail "Unknown command #{argv[0]}"
      end
    end

    def build
      builder.build
    end

    protected

    def builder
      @builder ||= Hodor::Builder.new(Dir.pwd)
    end
  end
end
