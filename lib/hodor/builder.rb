module Hodor
  class Builder
    attr_reader :app_path

    def initialize(app_path)
      @app_path = app_path
    end

    def image_name
      File.basename(app_path)
    end

    def build
    end
  end
end
