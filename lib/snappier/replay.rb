# frozen_string_literal: true

require_relative "registry"
require_relative "changes"

module Snappier
  module Replay
    def self.for(type:, id:)
      previous_state = {}

      Registry.persistence.each(type: type, id: id) do |current|
        content = current.delete(:content)
        current[:who] = content.delete("who")
        current[:state] = content.delete("state")
        current[:changes] = Changes.between(previous_state, current[:state])

        yield(current)

        previous_state = current[:state]
      end
    end

    def self.for_entity(entity)
      self.for(type: entity.class.name, id: entity.id)
    end
  end
end
