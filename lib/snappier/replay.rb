# frozen_string_literal: true

require_relative "registry"

module Snappier
  module Replay
    def self.for(type:, id:)
      previous_state = {}

      Registry.persistence.each(type: type, id: id) do |current|
        content = current.delete(:content)
        current[:who] = content.delete("who")
        current[:state] = content.delete("state")
        current[:changes] = changes(previous_state, current[:state])

        yield(current)

        previous_state = current[:state]
      end
    end

    def self.changes(previous_state, current_state)
      changes = {}

      keys = Set.new(previous_state.keys + current_state.keys)

      keys.each do |key|
        next if previous_state[key] == current_state[key]

        changes[key] = [previous_state[key], current_state[key]]
      end

      changes
    end

    def self.for_entity(entity)
      self.for(type: entity.class.name, id: entity.id)
    end
  end
end
