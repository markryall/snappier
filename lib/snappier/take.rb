# frozen_string_literal: true

require_relative "registry"
require_relative "job"
require_relative "who"
require "json"

module Snappier
  module Take
    def self.for(entity)
      action = "update"
      action = "create" if entity.previously_new_record?
      action = "destroy" if entity.destroyed?

      snapper = Registry.for_entity(entity)
      state = snapper ? snapper.snap(entity) : entity.attributes

      Job.perform_async(
        "at" => Time.now.strftime("%s%L"),
        "action" => action,
        "id" => entity.id,
        "type" => entity.class.name,
        "state" => state.to_json,
        "who" => Who.current,
      )

      entity
    end
  end
end
