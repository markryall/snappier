# frozen_string_literal: true

require_relative "registry"
require "sidekiq"
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

      Registry.persistence.persist(
        type: type,
        id: id,
        at: at,
        args: args,
      )
    end
  end
end
