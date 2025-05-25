# frozen_string_literal: true

require "fileutils"

module Snappier
  class FilePersistence
    def persist(type:, id:, at:, args:)
      path = File.join("tmp", "snappier", type, id, "#{at}.yml")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, args.to_yaml)
    end

    def each(type:, id:)
      dir_path = File.join("tmp", "snappier", type.to_s, id)
      Dir["#{dir_path}/*.yml"].each do |file_path|
        milliseconds = File.basename(file_path).split(".").first
        yield(
          {
            at: Time.at(milliseconds.to_i / 1000),
            content: YAML.load_file(file_path)
          }
        )
      end
    end
  end
end
