# frozen_string_literal: true

require "sidekiq"
require "fileutils"
require "yaml"

module Snappier
  class Job
    include Sidekiq::Job

    def perform(args)
      type = args["type"]
      id = args["id"]
      at = args["at"]

      args["at"] = Time.at(at.to_i / 1000).to_s
      args["state"] = JSON.parse(args["state"])

      path = File.join("tmp", "snappier", type, id, "#{at}.yml")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, args.to_yaml)
    end
  end
end
